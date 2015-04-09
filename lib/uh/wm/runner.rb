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

      attr_reader :env, :events, :manager

      def initialize env, manager: nil, stopped: false
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager || Manager.new(@events)
        @stopped  = stopped
      end

      def stopped?
        !!@stopped
      end

      def stop!
        @stopped = true
      end

      def register_event_hooks
        register_key_bindings_hooks
      end

      def connect_manager
        @manager.connect
        @env.log "Connected to X server"
        @manager.grab_key :q
      end

      def run_until &block
        @manager.handle_pending_events until block.call
      end


      private

      def register_key_bindings_hooks
        @events.on(:key, :q) { stop! }
      end
    end
  end
end
