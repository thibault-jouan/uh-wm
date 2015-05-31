uhwm
====

[![Version      ][badge-version-img]][badge-version-uri]
[![Build status ][badge-build-img]][badge-build-uri]
[![Code Climate ][badge-cclimate-img]][badge-cclimate-uri]


  uhwm is a minimalistic tiling and stacking window manager for X. It
shares some similarities with dwm and wmii, but is written in ruby so
you can configure and extend features directly with ruby code.

  The layout strategy is interchangeable, the default one being the
`uh-layout` ruby gem. A layout is a simple ruby object responding to
specific messages, so it's easy to write your own layout.

  Main features:

  * Xinerama support;
  * different adapters for event handling: blocking, multiplexing
    with `select()` or `kqueue()`;
  * configuration with a run control file;
  * key bindings with user defined code as callback;
  * configurable modifier key;
  * support user-defined layout strategies;
  * external program execution;
  * no re-parenting (therefore, no window decoration either);
  * no grabbing of the modifier key alone;
  * no mouse handling;
  * no EWMH support;
  * very limited ICCCM support.


Installation
------------

  uhwm requires ruby ~> 2.1 with rubygems, and is currently
distributed as the `uh-wm` ruby gem.

```
$ gem install uh-wm
```


Usage
-----

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


Configuration
-------------

  uhwm can be configured with a run control file written in ruby. A
simple example is provided below, more details are available in the
[`RunControl` class documentation][run_control_doc].

``` ruby
DMENU     = 'dmenu_run -b'.freeze
VT        = 'urxvt'.freeze
BROWSERS  = %w[
  arora chromium firebird firefox galeon iceweasel konqueror pentadactyl
  phoenix vimperator
].freeze


modifier :mod1                # This key is added to the modifier mask for *all*
                              # key bindings.
key(:p)     { execute DMENU } # Execute given command in a shell when mod1+shift
                              # is pressed.
key(:Q)     { quit }          # Quit when mod1+shift+q is pressed (a capitalized
                              # key adds shift to mod mask).
key(:enter) { execute VT }    # Common key names (`enter') are translated to
                              # their X equivalent (`return').

rule BROWSERS do              # Move windows to the `www' view when their app
  layout_view_set 'www'       # class match either /\Aarora/, /\Achromium/… etc
end

launch do                         # Execute urxvt program twice, synchronously.
  execute! VT                     # `execute!' is a variant of `execute' which
  execute! VT                     # return when a window is mapped.
  layout_client_column_set :succ  # Move last mapped window to next column.
end
```

  Blocks given to `key`, `rule`, `launch` are executed in a special
context providing access to methods named "actions", which are
described in the following section.

[run_control_doc]: http://www.rubydoc.info/gems/uh-wm/Uh/WM/RunControl


Actions
-------

  The actions DSL implements a few built-in messages, but also acts as
a proxy to the layout. Any message prefixed with `layout_` is
forwarded to the layout, with its prefix stripped. That is, if
`layout_view_sel '2'` is evaluated, then the layout will receive the
`view_sel` message with `"2"` as argument. Accurate information is
available in the [`ActionsHandler` class documentation][actions_doc]

| Message       | Arguments | Description
| ------------- | --------- | -----------------------------------
| quit          |           | requests uhwm to terminate
| execute       | command   | executes given `command` in a shell
| kill_current  |           | kills layout current client
| layout\_\*    | \*\_      | forwards messages to layout

[actions_doc]: http://www.rubydoc.info/gems/uh-wm/Uh/WM/ActionsHandler



[badge-version-img]:  https://img.shields.io/gem/v/uh-wm.svg?style=flat-square
[badge-version-uri]:  https://rubygems.org/gems/uh-wm
[badge-build-img]:    https://img.shields.io/travis/tjouan/uh-wm/master.svg?style=flat-square
[badge-build-uri]:    https://travis-ci.org/tjouan/uh-wm
[badge-cclimate-img]: https://img.shields.io/codeclimate/github/tjouan/uh-wm.svg?style=flat-square
[badge-cclimate-uri]: https://codeclimate.com/github/tjouan/uh-wm
