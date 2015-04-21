require 'uh'

module Uh
  module WM
    module Testing
      module AcceptanceHelpers
        TIMEOUT_DEFAULT = 2
        QUIT_KEYBINDING = 'alt+shift+q'.freeze
        LOG_CONNECTED   = 'Connected to'.freeze

        def uhwm_run options = '-v'
          command = %w[uhwm]
          command << options if options
          @interactive = @process = run command.join ' '
        end

        def uhwm
          @process
        end

        def uhwm_request_quit
          x_key QUIT_KEYBINDING
        end

        def uhwm_ensure_stop
          if @process
            x_key 'alt+shift+q'
            @process.terminate
          end
        end

        def uhwm_wait_output message
          output = -> { @process.stdout + @process.stderr }
          timeout_until do
            case message
              when Regexp then output.call =~ message
              when String then output.call.include? message
            end
          end
        rescue TimeoutError => e
          fail [
            "expected `#{message}' not seen after #{e.timeout} seconds in:",
            "  ```\n#{output.call.lines.map { |e| "  #{e}" }.join}  ```"
          ].join "\n"
        end

        def uhwm_run_wait_ready options = nil
          if options then uhwm_run options else uhwm_run end
          uhwm_wait_output LOG_CONNECTED
        end

        def with_other_wm
          @other_wm = ChildProcess.build('twm')
          @other_wm.start
          yield
          @other_wm.stop
        end

        def other_wm
          @other_wm
        end

        def x_client ident: :default
          @x_clients        ||= {}
          @x_clients[ident] ||= XClient.new(ident)
        end

        def x_focused_window_id
          Integer(`xdpyinfo`[/^focus:\s+window\s+(0x\h+)/, 1])
        end

        def x_input_event_masks
          `xdpyinfo`[/current input event mask:\s+0x\h+([\w\s]+):/, 1]
            .split(/\s+/)
            .grep /Mask\z/
        end

        def x_key k
          fail "cannot simulate X key `#{k}'" unless system "xdotool key #{k}"
        end

        def x_socket_check pid
          case RbConfig::CONFIG['host_os']
          when /linux/
            `netstat -xp 2> /dev/null`.lines.grep /\s+#{pid}\/ruby/
          else
            `sockstat -u`.lines.grep /\s+ruby.+\s+#{pid}/
          end.any?
        end

        def x_window_id **options
          x_client(options).window_id
        end

        def x_window_name
          x_client.window_name
        end

        def x_window_map times: 1, **options
          times.times { x_client(options).map }
          x_client(options).sync
        end

        def x_window_map_state **options
          `xwininfo -id #{x_window_id options}`[/Map State: (\w+)/, 1]
        end

        def x_window_unmap **options
          x_client(options).unmap
          x_client(options).sync
        end

        def x_window_destroy **options
          x_client(options).destroy
          x_client(options).sync
        end

        def x_clients_ensure_stop
          @x_clients and @x_clients.any? and @x_clients.values.each &:terminate
        end


        private

        def timeout_until
          timeout = ENV.key?('UHWMTEST_TIMEOUT') ?
            ENV['UHWMTEST_TIMEOUT'].to_i :
            TIMEOUT_DEFAULT
          Timeout.timeout(timeout) do
            loop do
              break if yield
              sleep 0.1
            end
          end
        rescue Timeout::Error
          fail TimeoutError.new('execution expired', timeout)
        end


        class TimeoutError < ::StandardError
          attr_reader :timeout

          def initialize message, timeout
            super message
            @timeout = timeout
          end
        end

        class XClient
          attr_reader :name

          def initialize name = object_id
            @name     = "#{self.class.name.split('::').last}/#{name}"
            @geo      = Geo.new(0, 0, 640, 480)
            @display  = Display.new.tap { |o| o.open }
          end

          def terminate
            @display.close
          end

          def sync
            @display.sync false
          end

          def window
            @window ||= @display.create_window(@geo).tap do |o|
              o.name = @name
            end
          end

          def window_id
            @window.id
          end

          def window_name
            @name
          end

          def map
            window.map
            self
          end

          def unmap
            window.unmap
            self
          end

          def destroy
            window.destroy
            self
          end
        end
      end
    end
  end
end
