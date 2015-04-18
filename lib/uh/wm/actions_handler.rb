module Uh
  module WM
    class ActionsHandler
      include EnvLogging

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
        log "Execute: #{command}"
        pid = fork do
          fork do
            Process.setsid
            begin
              exec command
            rescue Errno::ENOENT => e
              log_error "ExecuteError: #{e}"
            end
          end
        end
        Process.waitpid pid
      end
    end
  end
end
