+++
date = "2015-02-24T00:00:00Z"
title = "Solving problems with dependency management in Go"
aliases = ["solving-problems-with-dependency-management-in-go"]
+++

_This is a blog post I wrote for the GDS Technology blog. You can read
the original
[here](https://gdstechnology.blog.gov.uk/2015/02/24/solving-problems-with-dependency-management-in-go/)._

In a
[previous blog post](https://gdstechnology.blog.gov.uk/2014/11/14/using-go-in-government/)
we talked about how we use the programming language Go. But it only
briefly touched on the issue of
[dependency management](https://www.gov.uk/service-manual/making-software/dependency-management),
where Go is reliant on backwards compatible or vendored software. This
post is about what we’ve done about that.

### Libraries

As developers we regularly use other libraries or packages to help us
solve a problem rather than writing everything ourselves. Most
programming languages offer a dependency system for distributing
libraries. At GDS we use languages like Ruby, Python and Java and each
language has its preferred tool to manage these dependencies: bundler,
pip and gradle, for example.

Libraries installed through a package system can be installed
system-wide (known as site packages) or copied somewhere into the
directory containing the project (known as vendoring). However this
tripped us up when we started to use Go. This is because Go doesn’t
currently provide a way of defining specific versions of dependencies
to use. The language maintainers have
[publicly endorsed vendoring](http://golang.org/doc/faq#get_version)
of dependencies, but this isn’t always productive when you want an
easy way to keep various dependencies up to date.

### Dependencies in Go

Dependencies in Go are downloaded using the `go get` tool and placed
into a directory determined by the `$GOPATH` environment
variable. Dependencies aren’t explicitly pinned to a version and the
recommended model of development is to always keep the master branch
backwards compatible and up-to-date, or to vendor dependencies as
required.

If two developers were to work on a single project at two points in
time, with some difference in-between. And the dependencies that were
used had changed during this time. Then the software they’d be working
on would be different and could cause issues.

This was a problem for us because we wanted to make sure that the
various services we write in Go can always be compiled using specific
versions of each library we were using.

### Pinning dependencies to specific versions

The most common way to define specific versions of dependencies is to
create a dependency file that references specific tags or commits in
the different packaging systems the code is located in.

The dependency management tool is used to get, build and install the
library. One advantage is that your project repository continues to
only use the specific library with the state you expect.

### Pinning dependencies to specific versions in Go

`go get` does not have an explicit concept of versions. As a result,
different members of a team could be importing different versions of
any libraries being used. This is less than ideal.

Different dependencies may introduce incompatibilities, security
vulnerabilities, or be removed entirely. For these reasons, it’s
better to have more control over the upgrade process when building a
real-world application.

### What have we chosen?

As well as being able to pin versions of libraries we use, another
requirement for us was being able to compile and run Go code without
requiring a global `$GOPATH` to be in place.

Our current solution is either [Godep](https://github.com/tools/godep)
or [gom](https://github.com/mattn/gom), depending on the
project. We’ve chosen two options because different projects have
different requirements. For some projects we want to pin a specific
version but don’t mind downloading dependencies and don’t require a
fixed `$GOPATH`. Whereas for others we want to vendor the dependencies
because of how we view the code and the respective binary we generate.

### Godep vs. gom

Godep’s preferred specification format is JSON. It will create a
dependency file and create copies of all of your libraries into a
`Godeps` directory at the root of your package. The expectation being
that the libraries will be checked in with the rest of your code once
you start using Godep.

In comparison, gom is very similar to Ruby’s bundler. It expects a
Gomfile to list the dependencies of the project, in a Ruby-like syntax
which will be familiar to Bundler users. The dependencies are
downloaded into a `_vendor` directory and there’s no need to
explicitly check this into source control if you don’t need to. One
added bonus for gom is that if the gom tool is available on your
`$PATH` there’s no need to compile your project within a `$GOPATH` as
this will be automatically set to use the specific dependencies you
reference in your Gomfile.

### What next?

For now, both Godep and gom works for us. Should a consensus emerge
from the Go community over what to use, we’ll look at switching again.
