+++
date = "2014-08-27T00:00:00Z"
title = "Taking another look at GOV.UK’s disaster recovery"
aliases = ["taking-another-look-at-gov-uks-disaster-recovery"]
+++

_This is a blog post I wrote for the GDS Technology blog. You can read
the original
[here](https://gdstechnology.blog.gov.uk/2014/08/27/taking-another-look-at-gov-uks-disaster-recovery/)._

As GOV.UK gets bigger, we often need to revisit the ways that we
originally solved some problems. One thing that’s changed recently is
how we prepare for disaster recovery.

### Disaster Recovery

The reality of working in technology is that software systems fail,
more often than we’d like and usually in ways that are beyond our
control. The process of thinking up high-level failure scenarios and
solutions for them is called
[disaster recovery](http://en.wikipedia.org/wiki/Disaster_recovery).

One extreme scenario for GOV.UK is that all our infrastructure
disappears. All of of our applications, the servers they run on and
even the infrastructure provider we’re using. Gone.

Trying to solve this problem directly and up front is difficult. It’s
too generic and we don’t know the root cause yet. But, we can give
ourselves some time while we assess the situation and start to resume
normal service for our users.

### Creating a static copy of GOV.UK

Back in 2012, one of the nice properties of GOV.UK was that the
majority of pages were static. Static HTML, CSS, JavaScript and
images. Additionally, there were only 20,000 pages in total.

One of our solutions at the time was to run a task overnight to visit
every page on GOV.UK that wasn’t a form and save it to disk. This
process would take a couple of hours to complete. We’d then transfer
the files to some backup machines that were ready to be switched over
to should the worst occur.

We called the code that did this the GOV.UK Mirror.

### Fast forward to present day

Various agencies and departments have transitioned to GOV.UK and we’re
now up to over 140,000 pages. We found that the GOV.UK Mirror was now
taking close to 50 hours to complete. It meant that a given page could
be up to two days out of date should we need to switch to our
mirror. For pages like foreign travel advice that update more
regularly than once a day this was a problem.

### What problems are we trying to solve?

We knew that the full crawl was taking too long at 50 hours. We would
want this to complete within a day. We also couldn’t crawl certain
pages that get updated often on an ad-hoc basis such as foreign travel
advice. Finally, there was no way of pausing or stopping the mirror
process mid-run. We couldn’t continue easily from the last good state
so we had to restart from the beginning each time.

### Building it

We made a conscious decision to split the GOV.UK Mirror into two
components. A producer to give us the initial set of URLs and a
consumer to crawl them, and write the pages to disk. The two
components would communicate using a message queue. This way, we’d
remove our reliance on the nightly task to complete the work and could
use the message queue for crawling ad-hoc pages. Using a message queue
also meant we could continue where we left off.

The producer is now a simpler process that retrieves a list of URLs
from our [Content API](https://github.com/alphagov/govuk_content_api)
and publishes them to an exchange. Most of the work is done in the
consumer component, which is written in Go and the message queue
broker we’re using is RabbitMQ.

We wanted the ability to horizontally scale out crawling to improve
the rate at which we completed the work we were given. We could
achieve parallelism on the queue by increasing the number of
consumers, but we wouldn’t be able to keep track of URLs that had been
crawled across the nodes. We needed to think beyond a single process
running at one time.

We used Redis to share state across the workers. We use Redis to keep
track of URLs that had been crawled before and check whether or not to
crawl them as we pick up URLs from the message queue. Now we can have
many message queue consumers to get through work faster based on our
workload. The total time for a full crawl is now 4 hours.

### What have we learnt?

We had been running the GOV.UK Mirror for long enough to know which
areas we didn’t like, from operating it through to functionality we
knew to be missing. Not only that, but we also understood the problem
better than we did at GOV.UK’s release. There was no magical epiphany
that occurred; this is the nature of writing software – you have to
adapt and update as you know more.

After two years of running GOV.UK we’re finding that we have to
revisit many of the choices we had made. The site has grown a lot and
it’s time to take another look at many of the applications we built
back in 2012.

[Iterate. Then iterate again.](https://www.gov.uk/design-principles#fifth)
