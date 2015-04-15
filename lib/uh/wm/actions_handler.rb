module Uh
  module WM
    class ActionsHandler
      def initialize env, events
        @env, @events = env, events
      end

      def evaluate code
        instance_eval &code
      end

      def quit
        @events.emit :quit
      end
    end
  end
end
