module Uh
  module WM
    class Runner
      class << self
        def run env, **options
          runner = new env, **options
          runner.connect_manager
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

      def connect_manager
        @manager.connect
        @env.log "Connected to X server"
      end
    end
  end
end
