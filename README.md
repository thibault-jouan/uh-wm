uh-wm
=====

[![Version      ][badge-version-img]][badge-version-uri]
[![Build status ][badge-build-img]][badge-build-uri]
[![Code Climate ][badge-cclimate-img]][badge-cclimate-uri]


  uh-wm is a minimalistic tiling and stacking window manager for X. It
shares some similarities with dwm and wmii, but is written in ruby so
you can configure and extend features with ruby code.

  The layout strategy is interchangeable, the default one being the
`uh-layout` ruby gem. A layout is a simple ruby object responding to
specific methods.

  Main features:

  * Xinerama support;
  * Multiple event handling strategy: blocking or multiplexing
    (`select()`);
  * Configuration with a run control file (ruby DSL);
  * Key bindings with user defined code as callback;
  * Configurable modifier key;
  * Support user-defined layout strategies;
  * Program execution;

  * No re-parenting (therefore, no window decoration either);
  * No grabbing of the modifier key alone;
  * No mouse handling;
  * Very limited ICCCM support.


Getting started
---------------

### Installation (requires ruby ~> 2.1 with rubygems)

```
$ gem install uh-wm
```


### Usage

```
Usage: uhwm [options]

options:
    -v, --verbose                    enable verbose mode
    -d, --debug                      enable debug mode
    -f, --run-control PATH           specify alternate run control file
    -r, --require PATH               require ruby feature
    -l, --layout LAYOUT              specify layout
    -w, --worker WORKER              specify worker

    -h, --help                       print this message
    -V, --version                    print version
```



[badge-version-img]:  https://img.shields.io/gem/v/uh-wm.svg?style=flat-square
[badge-version-uri]:  https://rubygems.org/gems/uh-wm
[badge-build-img]:    https://img.shields.io/travis/tjouan/uh-wm/master.svg?style=flat-square
[badge-build-uri]:    https://travis-ci.org/tjouan/uh-wm
[badge-cclimate-img]: https://img.shields.io/codeclimate/github/tjouan/uh-wm.svg?style=flat-square
[badge-cclimate-uri]: https://codeclimate.com/github/tjouan/uh-wm
