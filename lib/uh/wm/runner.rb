module Uh
  module WM
    class Runner
      class << self
        def run env, **options
          runner = new env, **options
          runner.register_event_hooks
          runner.connect_manager
          runner.run_until { runner.stopped? }
        end
      end

      attr_reader :env, :events, :manager, :layout

      def initialize env, manager: nil, stopped: false
        raise ArgumentError, 'missing env layout class' unless env.layout_class
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager || Manager.new(@events)
        @layout   = @env.layout_class.new
        @stopped  = stopped
      end

      def stopped?
        !!@stopped
      end

      def stop!
        @stopped = true
      end

      def register_event_hooks
        register_manager_hooks
        register_layout_event_hooks
        register_key_bindings_hooks
      end

      def connect_manager
        @manager.connect
        @manager.grab_key :q
      end

      def run_until &block
        @manager.handle_pending_events until block.call
      end


      private

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
          @layout.register display
        end
      end

      def register_key_bindings_hooks
        @events.on(:key, :q) { stop! }
      end
    end
  end
end
