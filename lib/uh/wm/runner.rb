module Uh
  module WM
    class Runner
      class << self
        def run env
          runner = new env
          runner.connect_manager
        end
      end

      attr_reader :env, :manager

      def initialize env, manager: Manager.new
        @env      = env
        @manager  = manager
      end

      def connect_manager
        @manager.connect
        @env.log "Connected to X server"
      end
    end
  end
end
