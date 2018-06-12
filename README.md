# violentlymild.com

This repository contains all of the content and themes necessary to
generate the content for https://www.violentlymild.com/

## Dependencies

The content is written in
[Markdown](https://daringfireball.net/projects/markdown/) and the
website can be generated using [Hugo](https://gohugo.io/).

## Building

You can build the website using the provided `Makefile`:

```
$ make build
```

## Development

A useful way to iterate on this repository and see the result of your
changes is to use
[watchman](https://facebook.github.io/watchman/). Then you can
integrate watchman with `make` by running the following to have the
project rebuilt on each change:

```
$ watchman-make -p 'content/**' -t build -p 'static/**' -t build -p 'themes/**' -t build
```
