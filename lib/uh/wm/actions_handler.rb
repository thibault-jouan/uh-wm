module Uh
  module WM
    class ActionsHandler
      include EnvLogging

      extend Forwardable
      def_delegator :@env, :layout

      def initialize env, events
        @env, @events = env, events
      end

      def evaluate code = nil, &block
        if code
          instance_exec &code
        else
          instance_exec &block
        end
      end

      def quit
        log 'Quit requested'
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

      def kill_current
        layout.current_client.kill
      end

      def log_separator
        log '- ' * 24
      end

      def method_missing(m, *args, &block)
        if respond_to? m
          meth = layout_method m
          log "#{layout.class.name}##{meth} #{args.inspect}"
          begin
            layout.send(meth, *args)
          rescue NoMethodError
            log_error "Layout does not implement `#{meth}'"
          end
        else
          super
        end
      end

      def respond_to_missing?(m, *)
        m.to_s =~ /\Alayout_/ || super
      end


      private

      def layout_method(m)
        m.to_s.gsub(/\Alayout_/, 'handle_').to_sym
      end
    end
  end
end
