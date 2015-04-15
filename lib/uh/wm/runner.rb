module Uh
  module WM
    class Runner
      class << self
        def run env, **options
          runner = new env, **options
          runner.evaluate_run_control
          runner.register_event_hooks
          runner.connect_manager
          runner.run_until { runner.stopped? }
        end
      end

      extend Forwardable
      def_delegator :@env, :layout

      attr_reader :env, :events, :manager, :actions

      def initialize env, manager: nil, stopped: false
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager || Manager.new(@events)
        @actions  = ActionsHandler.new(@env, @events)
        @stopped  = stopped
      end

      def stopped?
        !!@stopped
      end

      def stop!
        @stopped = true
      end

      def evaluate_run_control
        RunControl.evaluate(env)
      end

      def register_event_hooks
        register_runner_hooks
        register_manager_hooks
        register_layout_event_hooks
        register_key_bindings_hooks
      end

      def connect_manager
        @manager.connect
        @env.keybinds.each do |keysym, _|
          @manager.grab_key *keysym
        end
      end

      def run_until &block
        @manager.handle_pending_events until block.call
      end


      private

      def register_runner_hooks
        @events.on(:quit) { stop! }
      end

      def register_manager_hooks
        @events.on(:connecting) do |display|
          @env.log_debug "Connecting to X server on `#{display}'"
        end
        @events.on(:connected) do |display|
          @env.log "Connected to X server on `#{display}'"
        end
      end

      def register_layout_event_hooks
        @events.on(:connected) do |display|
          layout.register display
        end
      end

      def register_key_bindings_hooks
        @env.keybinds.each do |keysym, code|
          @events.on :key, *keysym do
            @actions.evaluate code
          end
        end
      end
    end
  end
end
