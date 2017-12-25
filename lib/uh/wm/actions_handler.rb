module Uh
  module WM
    # Provides a context with helper methods for key bindings
    # ({RunControl#key}), client rules ({RunControl#rule}) and the {Launcher}
    # ({RunControl#launch}).
    class ActionsHandler
      include EnvLogging

      extend Forwardable
      # @!method layout
      #   Returns the layout
      #   @return [Object] The layout
      #   @see Env#layout
      def_delegator :@env, :layout

      # @api private
      # @param env [Env] An environment
      # @param events [Dispatcher] A dispatcher
      def initialize env, events
        @env    = env
        @events = events
      end

      # Evaluates action code given as normal argument or block parameter
      # @api private
      # @param code [Proc] Action code
      # @param block [Proc] Action code
      def evaluate code = nil, &block
        if code
          instance_exec &code
        else
          instance_exec &block
        end
      end

      # Executes given command. Forks twice, creates a new session and makes
      # the new process the session leader and process group leader of a new
      # process group. The new process has no controlling terminal.  Refer to
      # `fork(2)` and `setsid(2)` for more detail.
      #
      # `command` argument is executed with `Kernel#exec`.
      #
      # @param command [String, Array] Command to execute
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

      # Kills layout current client (focused) with {Client#kill}
      def kill_current
        return unless layout.current_client
        layout.current_client.kill
      end

      # Logs a separator string, can help during debug
      def log_separator
        log '- ' * 24
      end

      # Forwards unhandled messages prefixed with `layout_` to the layout,
      # replacing the prefix with `handle_`
      # @example
      #   layout_foo # delegates to `layout.handle_foo'
      def method_missing m, *args, &block
        if respond_to? m
          meth = layout_method m
          log "#{layout.class.name}##{meth} #{args.inspect}"
          if layout.respond_to? meth
            layout.send meth, *args
          else
            log_error "Layout does not implement `#{meth}'"
          end
        else
          super
        end
      end

      # Requests the window manager to terminate
      def quit
        log 'Quit requested'
        @events.emit :quit
      end

      # Checks method existence in layout
      # @api private
      def respond_to_missing? m, _
        m.to_s =~ /\Alayout_/ || super
      end

    private

      def layout_method m
        m.to_s.gsub(/\Alayout_/, 'handle_').to_sym
      end
    end
  end
end
