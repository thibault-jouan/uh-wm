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
          runner.terminate
        end
      end

      extend Forwardable
      def_delegator :@env, :layout

      attr_reader :env, :events, :actions

      def initialize env, manager: nil, stopped: false
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager
        @actions  = ActionsHandler.new(@env, @events)
        @stopped  = stopped
      end

      def stopped?
        !!@stopped
      end

      def stop!
        @stopped = true
      end

      def manager
        @manager ||= Manager.new(@events, @env.modifier)
      end

      def evaluate_run_control
        RunControl.evaluate(env)
      end

      def register_event_hooks
        %w[runner manager layout keybinds]
          .map  { |e| "register_#{e}_hooks".to_sym }
          .each { |e| send e }
      end

      def connect_manager
        manager.connect
        @env.keybinds.each do |keysym, _|
          manager.grab_key *keysym
        end
      end

      def run_until &block
        manager.handle_pending_events until block.call
      end

      def terminate
        @env.log "Terminating..."
        manager.disconnect
      end


      private

      def register_runner_hooks
        @events.on(:quit) { stop! }
      end

      def register_manager_hooks
        @events.on :connecting do |display|
          @env.log_debug "Connecting to X server on `#{display}'"
        end
        @events.on :connected do |display|
          @env.log "Connected to X server on `#{display}'"
        end
        @events.on(:disconnected) { @env.log "Disconnected from X server" }
        @events.on(:xevent) { |event| XEventLogger.new(env).log_event event }
      end

      def register_layout_hooks
        @events.on :connected do |display|
          layout.register display
        end
        @events.on :manage do |client|
          layout << client
        end
      end

      def register_keybinds_hooks
        @env.keybinds.each do |keysym, code|
          @events.on(:key, *keysym) { @actions.evaluate code }
        end
      end


      class XEventLogger
        def initialize env
          @env = env
        end

        def log_event xev
          complement = case xev.type
          when :key_press
            "window: #{xev.window} key: #{xev.key} mask: #{xev.modifier_mask}"
          when :map_request
            "window: #{xev.window}"
          end

          @env.log_debug [
            'XEvent',
            xev.type,
            xev.send_event ? 'SENT' : nil,
            complement
          ].compact.join ' '
        end
      end
    end
  end
end
