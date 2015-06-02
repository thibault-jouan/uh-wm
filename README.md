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
  * user-defined layout strategies;
  * external program execution;
  * no re-parenting (therefore, no window decoration either);
  * no grabbing of the modifier key alone;
  * no default key binding except for exiting;
  * no mouse event handling;
  * no EWMH support;
  * very limited ICCCM support.


Installation
------------

  uhwm requires ruby ~> 2.1 with rubygems, and is currently
distributed as the `uh-wm` ruby gem.

``` shell
gem install uh-wm   # install the gem or update to last release
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
[`RunControl` class documentation][run_control_doc]. The file must be
located at the `~/.uhwmrc.rb` path.

  Please note that uhwm ships with only one key binding: `mod+shift+q`
which is bound to the `quit` action. You *need* to write your own
configuration file if you want to do something useful with uhwm.

``` ruby
DMENU     = 'dmenu_run -b'
VT        = 'urxvt'
BROWSERS  = %w[
  arora chromium firebird firefox galeon iceweasel konqueror pentadactyl
  phoenix vimperator
]


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


Hacking uhwm
------------

  If you need to work with uhwm source code, you will need a local clone
of the repository. A bundler `Gemfile` is provided, and if you are new
to ruby and rubygems, we recommend that you use bundler to manage
dependencies. Refer to the bundler documentation if you need no know
more than this short help:

  * Run `bundle install` after you update the repository sources to a
    new version, or when you changes branches which affect the
    `Gemfile`
  * Prefix every ruby executable scripts (`bin/uhwm`, `rake`…) with
    `bundle exec`, for example `bundle exec rake spec`

  Please note this not the "supported" way of using uhwm, we recommend
that you use the ruby gem. The `master` branch can sometimes receive
experimental features which may need improvements before a stable gem
release.

### Installation with bundler

``` shell
git clone git://github.com/tjouan/uh-wm   # clone repository from github mirror
bundle install                            # install dependencies with bundler
```

### Running the test suite

``` shell
rake            # Run all test suites
rake features   # Run user acceptance test suite
cucumber        # Run user acceptance test suite
rake spec       # Run unit test suite
rspec           # Run unit test suite
```

  Prefix the commands as `bundle exec COMMAND` if you're using
bundler.

### Running uhwm within a nested X session

  For convenience, the `run` rake task is provided to execute uhwm in
a new X session using Xephyr as the X server. The session is
initialized with the `startx` program, the task will import the keymap
from your current X session to the new one and change the background
color to one that is neither used by uhwm nor commonly used by other.

``` shell
# Run uhwm (with default argument `-d', set by the task internally)
rake run
# Run uhwm with no argument
rake run --
# Run uhwm with `-v' argument
rake run -- -v
# Setup Xephyr with two screens
rake run UHWM_XINERAMA=yes
# Combine custom env and custom uhwm arguments
rake run UHWM_XINERAMA=yes -- -v
```


Extensive configuration example
-------------------------------

``` ruby
COLORS    = {
  bg:   'rgb:0c/0c/0c'.freeze,
  fg:   'rgb:d0/d0/d0'.freeze,
  sel:  'rgb:d7/00/5f'.freeze,
  hi:   'rgb:82/00/3a'.freeze
}.freeze
DMENU     = ('dmenu_run -b -nb %s -nf %s -sb %s -sf %s' %
              COLORS.values_at(:bg, :fg, :sel, :fg)).freeze
VT        = 'urxvt'.freeze
VT_SHELL  = "#{VT} -e zsh -i -c".freeze
LOCKER    = 'xautolock -locknow &'.freeze
BROWSERS  = %w[
  arora chrome chromium firebird firefox galeon iceweasel konqueror pentadactyl
  phoenix vimperator
].freeze
DATETIME  = -> { Time.new.strftime('%FT%T %a') }.freeze


worker    :kqueue, timeout: 1
modifier  :mod1
layout    colors: COLORS, bar_status: DATETIME

key(:Q)           { quit }
key(:z)           { execute LOCKER }

key(:enter)       { execute VT }
key(:p)           { execute DMENU }

key(:c)           { layout_screen_sel :succ }
key(:C)           { layout_screen_set :succ }
(0..9).each       { |e| key(e)          { layout_view_sel e } }
(0..9).each       { |e| key(e, :shift)  { layout_view_set e } }
key(:w)           { layout_view_sel 'www' }
key(:W)           { layout_view_set 'www' }
key(:h)           { layout_column_sel :pred }
key(:s)           { layout_column_sel :succ }
key(:n)           { layout_client_sel :pred }
key(:t)           { layout_client_sel :succ }
key(:d)           { layout_column_mode_toggle }
key(:N)           { layout_client_swap :pred }
key(:T)           { layout_client_swap :succ }
key(:H)           { layout_client_column_set :pred }
key(:S)           { layout_client_column_set :succ }

key(:tab)         { layout_history_view_pred }

key(:e)           { kill_current }

key(:apostrophe)  { execute 'mocp --toggle-pause' }
key(:comma)       { execute 'mixer vol -3' }
key(:period)      { execute 'mixer vol +3' }
key(:Apostrophe)  { execute 'mocp --seek 30' }
key(:Comma)       { execute 'mocp --previous' }
key(:Period)      { execute 'mocp --next' }

key(:l)           { log_layout }
key(:L)           { log_client }
key(:backspace)   { log_separator }

if ENV['DISPLAY'] == ':42'
  key(:q)         { quit }
  key(:f)         { execute VT }
  key(:F)         { execute 'firefox -P test' }
end

rule BROWSERS do
  layout_view_set 'www'
  next unless layout.current_view.columns.size == 1
  next unless layout.current_view.clients.size >= 2
  next unless layout.current_view.clients.any? { |c| c.wclass =~ /\A#{VT}/i }
  layout_client_column_set :succ
end

rule VT do
  next unless layout.current_view.columns.size == 1
  next unless layout.current_view.clients.size >= 2
  if layout.current_view.clients.all? { |c| c.wclass =~ /\A#{VT}/i }
    layout_client_column_set :succ
  elsif layout.current_view.clients.any? { |c| c.wclass =~ /\Afirefox/i }
    layout_client_column_set :pred
  end
end

rule 'xephyr' do
  if layout.current_view.clients.select { |c| c.wclass =~ /\Axephyr/i }.size > 1
    layout_screen_set :succ
    layout_view_set 7
    layout_view_sel 7
    layout_screen_sel :pred
    layout_screen_set :succ
    layout_column_mode_toggle
  else
    layout_client_column_set :succ
  end
end

launch do
  layout_screen_sel :succ

  layout_view_sel '2'
  execute! "#{VT_SHELL} 'tail -F ~/.uhwm.log'"

  layout_view_sel '1'
  execute! "#{VT_SHELL} mutt"
  layout_column_mode_toggle
  execute! "#{VT_SHELL} 'mtr -n foo.example; exec zsh'"
  execute! "#{VT_SHELL} 'mtr -n bar.example; exec zsh'"

  execute! "#{VT_SHELL} 'ssh -t foo.example zsh -i -c \\\"tmux attach -t irc\\\"; exec zsh'"
  layout_client_column_set :succ

  execute! "#{VT_SHELL} 'ssh -t foo.example tmux attach -t log; exec zsh'"
  layout_client_column_set :succ
  layout_column_mode_toggle
  execute! "#{VT_SHELL} 'ssh -t bar.example tmux attach -t log; exec zsh'"
  execute! "#{VT_SHELL} 'tmux attach -t log; exec zsh'"
  layout_column_sel :pred

  layout_screen_sel :pred

  execute! "#{VT_SHELL} mutt"
  execute! "#{VT_SHELL} 'vim ~/TODO; exec zsh'"
  layout_client_column_set :succ
  execute! VT
  layout_client_column_set :succ

  layout_view_sel '2'
  execute! "#{VT_SHELL} 'cd ~/src/.../uh-wm; exec zsh'"
  execute! "#{VT_SHELL} 'cd ~/src/.../uh-wm; exec zsh'"
  layout_client_column_set :pred

  layout_view_sel '4'
  execute! "#{VT_SHELL} mocp; exec zsh"
  execute! VT
  layout_client_column_set :succ

  layout_view_sel '8'
  execute! "#{VT_SHELL} 'top -o res; exec zsh'"
  execute! VT
  layout_client_column_set :succ

  layout_view_sel '1'
end if ENV['DISPLAY'] == ':0'

launch do
  layout_view_sel '2'
  execute! "#{VT_SHELL} 'tail -F ~/.uhwm.log'"

  layout_view_sel '1'
  execute! "#{VT_SHELL} 'echo hello\!; exec zsh'"
  execute! VT
  layout_client_column_set :succ
end if ENV['DISPLAY'] == ':42'
```


BUGS
----

* Signal handling is broken under certain undocumented conditions.

* Unicode is not supported everywhere (the `uh` ruby gem does not yet
  support unicode text drawing).

* Column width in default layout is hard coded.


FAQ
---

_uhwm is stealing focus, how can I avoid this behavior?_

  You can't (yet). The default layout will be modified to accept an
`autofocus: false` option in a future release.

_What are the default key bindings?_

  Juste one: `mod+shift+q` is bound to the `quit` action.

_How can I implement my own layout?_

  A layout is a simple ruby object responding to a set of messages:
`register`, `current_client`, `suggest_geo`, `<<`, `remove`, `update`
and `expose`. No documentation is available yet, so read the source
code or the cucumber scenarios in `features/layout/protocol.feature`.

_Can I change the default behavior ignoring current view selection?_

  Yes, just test for this condition in the key binding code. For
example the following code will select the last historized view (if
you are on view `"1"`, and select view `"2"` twice, the view `"1"` is
selected.

``` ruby
# Replace the "simple" view selection key binding...
key(:m) { layout_view_sel 'my_view' }
# ...with this:
key :m do
  if layout.current_view.id == 'my_view'
    layout_view_sel layout.history.last_view.id
  else
    layout_view_sel 'my_view'
  end
end
```
_I get a \`cannot load such file -- uh/wm (LoadError)\` how do I fix?_

  You are probably not using the gem. If you want to use uhwm from a
local git clone or if you did a custom install, try to use bundler or
to modify the ruby load path (set `RUBYOPT=lib` for example).



[badge-version-img]:  https://img.shields.io/gem/v/uh-wm.svg?style=flat-square
[badge-version-uri]:  https://rubygems.org/gems/uh-wm
[badge-build-img]:    https://img.shields.io/travis/tjouan/uh-wm/master.svg?style=flat-square
[badge-build-uri]:    https://travis-ci.org/tjouan/uh-wm
[badge-cclimate-img]: https://img.shields.io/codeclimate/github/tjouan/uh-wm.svg?style=flat-square
[badge-cclimate-uri]: https://codeclimate.com/github/tjouan/uh-wm
