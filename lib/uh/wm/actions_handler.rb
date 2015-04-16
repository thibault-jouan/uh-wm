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

      def execute command
        @env.log "Execute: #{command}"
        pid = fork do
          fork do
            Process.setsid
            begin
              exec command
            rescue Errno::ENOENT => e
              @env.log_error "ExecuteError: #{e}"
            end
          end
        end
        Process.waitpid pid
      end
    end
  end
end
