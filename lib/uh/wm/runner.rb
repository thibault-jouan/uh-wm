module Uh
  module WM
    class Runner
      class << self
        def run env
          runner = new env
          runner.connect_manager
        end
      end

      attr_reader :env, :events, :manager

      def initialize env, manager: Manager.new
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager
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
