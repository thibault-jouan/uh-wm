module Uh
  module WM
    # Provides the context and behavior for run control file evaluation.
    class RunControl
      # Key sym translations for key bindings.
      KEYSYM_TRANSLATIONS = {
        backspace:  :BackSpace,
        enter:      :Return,
        return:     :Return,
        tab:        :Tab
      }.freeze

      class << self
        # Builds an instance and evaluates any run control file defined in
        # the given {Env} instance
        # @api private
        # @param env [Env] An environment
        def evaluate env
          rc_path = File.expand_path(env.rc_path)
          rc = new env
          rc.evaluate File.read(rc_path), rc_path if File.exist?(rc_path)
        end
      end

      # @api private
      # @param env [Env] An environment
      def initialize env
        @env = env
      end

      # Evaluates run control code
      # @api private
      # @param code [String] The run control file content
      # @param path [String] The run control file path
      def evaluate code, path
        instance_eval code, path
      rescue ::StandardError, ::ScriptError => e
        raise RunControlEvaluationError, e.message, e.backtrace
      end

      # Registers a key binding
      # @example Output message on standard output when `modkey+f` is pressed
      #   key(:f) { puts 'hello world!' }
      # @example Add `shift` key sym to the modifier mask
      #   key(:q, :shift) { quit }
      # @example Convert capitalized key sym `Q` to `shift+q`
      #   key(:Q) { quit }
      # @example Convert `enter` to `return` X key sym
      #   key(:enter) { execute 'xterm' }
      # @param keysyms [Symbol] X key sym
      # @param block Code to execute when the key binding is triggered, with
      #   `self` as an {ActionsHandler} instance
      def key *keysyms, &block
        @env.keybinds[translate_keysym *keysyms] = block
      end

      # Declares code to execute on window manager connection
      # @example
      #   launch { execute 'xterm' }
      # @param block Code to execute when the window manager has connected,
      #   with `self` as a {Launcher} instance
      def launch &block
        @env.launch = block
      end

      # Defines the layout with either a layout class or an instance with
      # optional layout options. When given only a hash, configures options for
      # the default layout and ignores the `options` parameter.
      # @example
      #   layout MyLayout
      #   layout MyLayout, foo: :bar
      #   layout MyLayout.new
      #   layout MyLayout.new(foo: :bar)
      #   layout foo: :bar
      # @param arg [Class, Object, Hash] A layout class, a layout instance, or
      #   options for the default layout
      # @param options [Hash] Layout options
      def layout arg, **options
        case arg
        when Class
          if options.any?
            @env.layout = arg.new options
          else
            @env.layout_class = arg
          end
        when Hash
          @env.layout_options = arg
        else
          @env.layout = arg
        end
      end

      # Defines the modifier masks to use for key bindings
      # @example
      #   modifier :mod1 # Use `mod1' as modifier
      # @param keysym [Symbol] X key sym
      # @raise [RunControlArgumentError] if any given modifier is invalid
      def modifier keysym, ignore: []
        [keysym, *ignore].each do |mod|
          unless KEY_MODIFIERS.keys.include? mod
            fail RunControlArgumentError,
              "invalid modifier keysym `#{mod.inspect}'"
          end
        end
        @env.modifier         = keysym
        @env.modifier_ignore  = [*ignore]
      end

      # Declares a client rule
      # @example
      #   rule %w[firefox chrome] do
      #     log 'moving client to `www\' view!'
      #     layout_view_set 'www'
      #   end
      # @param selectors [String, Array<String>] Substring matched against the
      #   beginning of clients window application name
      # @param block Code to execute when the client rule is matched
      def rule selectors = '', &block
        [*selectors].each { |selector| @env.rules[/\A#{selector}/i] = block }
      end

      # Configures the worker
      # @example Use the blocking worker
      #   worker :block
      # @example Use the kqueue worker with 1 second timeout
      #   worker :kqueue, timeout: 1
      # @example Use the multiplexing (`select()`) worker with 1 second timeout
      #   worker :mux, timeout: 1
      # @param type [Symbol] Worker type: `:block`, `:kqueue` or `:mux`
      # @param options [Hash] Worker options
      # @raise [RunControlArgumentError] if worker type is invalid
      def worker type, **options
        unless Workers.type? type
          fail RunControlArgumentError, "invalid worker type `#{type}'"
        end
        @env.worker = [type, options]
      end


      private

      def translate_keysym keysym, modifier = nil
        return [translate_keysym(keysym)[0].to_sym, modifier] if modifier
        translate_key = keysym.to_s.downcase.to_sym
        translated_keysym = KEYSYM_TRANSLATIONS.key?(translate_key) ?
          KEYSYM_TRANSLATIONS[translate_key] :
          translate_key
        keysym =~ /[A-Z]/ ? [translated_keysym, :shift] : translated_keysym
      end
    end
  end
end
