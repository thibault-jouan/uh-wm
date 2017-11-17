uhwm
====

  uhwm is a minimalistic tiling and stacking window manager for X. It
is mostly written in ruby so you can configure and extend features
directly with ruby code.

  The layout behavior can be changed, the default one being
implemented by the `uh-layout` ruby gem. A layout is a simple ruby
object responding to specific messages, so you can write your own in
plain ruby without any dependency.

  Main features:

  * Xinerama support;
  * different adapters for event handling: blocking, multiplexing
    with `select()` or `kqueue()`;
  * configuration with a run control file;
  * key bindings with user defined callbacks;
  * configurable modifier key;
  * user-defined layout behavior (ruby);
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
distributed as the `uh-wm` ruby gem and the `x11-wm/rubygem-uh-wm`
FreeBSD port.

``` shell
gem install uh-wm   # install the gem or update to last release
```

``` shell
pkg install x11-wm/rubygem-uh-wm    # use the FreeBSD port
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
key(:p)     { execute DMENU } # Execute given command in a shell with mod1+p.
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
described in the "Actions" section of this file.

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


BUGS
----

* Unicode is not supported everywhere (the `uh` ruby gem does not yet
  support unicode text drawing).


FAQ
---

_What are the default key bindings?_

  Just one: `mod+shift+q` is bound to the `quit` action.

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
