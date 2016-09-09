+++
date = "2010-01-02T00:00:00Z"
title = "Designing an interface to create interfaces"
aliases = ["designing-an-interface-to-create-interfaces"]
+++

_I’ve been reading_ [_Coders at Work_](http://www.codersatwork.com/)
_recently and this blog post is spawned from a point made by_
[_Simon Peyton Jones_](http://research.microsoft.com/en-us/people/simonpj/)
_in the book — Page 252, Paragraph 3 — about creating usable
programming languages._

When the field of <abbr title="Human Computer Interaction">HCI</abbr>
was established in the early 1980s, learnability was the research
focus. By the late 1980s we had a handle on how to design for the
novice user, demonstrating that even the best commercially available
personal computer was much harder to learn than claimed by it’s
manufacturer.

We created computers because our ability to think using rigorous logic
is limited in terms of speed, capacity and accuracy. Given these
limitations, shouldn’t any interfaces we create play to our strengths
without demanding too much from our weaknesses?

Programming languages go through rapid development to fit formal
(hardware) specifications and have meant that usability best practices
have fallen by the way-side. However, usability is holistic and
something that has to be intentionally designed in from the beginning
rather than slapped on at the end.

Usability studies in this area are lacking, but there are
[some](http://www.ppig.org/papers/13th-clarke.pdf "Evaluating a new
programming language, by Steven Clarke") that have managed to have an
effect on the final product. More recently though, full on
[task forces](http://www.cs.cmu.edu/~NatProg/) have been springing up
and providing good information on **designing the interface that
creates the interface**.

### Testing products with a steep learning curve

As stated by Jakob Nielson in his
[Iterative User Interface Design](http://www.useit.com/papers/iterative_design/)
paper:

> For some user interfaces, full expertise may take several years to
> acquire, and even for simpler interfaces, one would normally need to
> train users for several weeks or months before their performance
> plateaued out at the expert level

Sadly, by the time you’ve learnt how to use the product effectively,
you’re too biased to comment on it’s usability fairly. This is just
one of the fundamental limits on usability testing of complicated
products. Despite this, there is still knowledge to be gained from
testing programming languages at a novice or intermediate level.

A simple programming test could be held, with people who have the same
amount of training — university students? — in different languages and
then measure factors ranging from the number of errors along the way,
to overall performance. A simple task may involve scraping data from a
set of web pages such as [last.fm](http://www.last.fm/) and organising
them into a searchable data structure. The user could attempt to use
any programming language but a time-limit would need to be set to keep
the test fair.

### Libraries vs. Languages

Being a programmer, I tend to look for solutions by dissecting the
problem into smaller chunks and in many cases that makes me lean
towards libraries. It’s likely that any seasoned developer would do
the same, opting for the _best tools_ for the job rather than any one
single language. Does this fulfil the _efficient use_ category of
usability? No.

Most of these libraries are built by software developers to facilitate
their work, increasing the need for usability in this particular
area. **If something is too time-consuming, a developer will automate
it. <span style="font-weight: normal;">However it does then raise the
question of whether the flaws lie in the language, where the expert
knowledge is needed to understand how to automate a given task in the
first place.</span>**

### Can we have a yardstick?

There is ample evidence to support the notion that experts behave
differently from novices, but that should never mean we pick one of
these two groups and design specifically for them. Program designers
should understand the context of use, set appropriate goals, and
measure that we are achieving those goals. The myriad of different
programming paradigms mean that we can’t effectively compare the
usability of different languages, but that shouldn’t hinder the
process of increasing usability for the lowest common denominator.

The lack of cross-over between Funtional, Procedural or even
Event-based programming languages makes formalising a test harness
extremely difficult. Attempting to test all of the different kinds of
programming languages may produce a clear winner in terms of
usability, but are likely to fail large proportions of the development
community.

_Disclaimer: I would never pretend to be an expert in this area, so
I’m sure there is a lot of good material that I’m not aware of
yet. Please let me know if you have any further useful information._
