require 'uh'

module Uh
  module WM
    module Testing
      module AcceptanceHelpers
        TIMEOUT_DEFAULT = 2
        QUIT_KEYBINDING = 'alt+shift+q'.freeze
        LOG_READY       = 'Working events'.freeze

        def icccm_window_start
          @icccm_window = ChildProcess.build(*%w[xmessage window])
          @icccm_window.start
        end

        def icccm_window_ensure_stop
          @icccm_window.stop
        end

        def icccm_window_name
          'xmessage'
        end

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

        def uhwm_wait_output message, times = 1, value = nil
          output = -> { @process.stdout + @process.stderr }
          timeout_until do
            case message
            when Regexp then (value = output.call.scan(message)).size >= times
            when String then output.call.include? message
            end
          end
          value
        rescue TimeoutError => e
          fail <<-eoh
expected `#{message}' (#{times}) not seen after #{e.timeout} seconds in:
  ```\n#{output.call.lines.map { |e| "  #{e}" }.join}  ```
          eoh
        end

        def uhwm_wait_ready
          uhwm_wait_output LOG_READY
        end

        def uhwm_run_wait_ready options = nil
          if options then uhwm_run options else uhwm_run end
          uhwm_wait_ready
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

        def x_client ident = nil
          ident             ||= :default
          @x_clients        ||= {}
          @x_clients[ident] ||= XClient.new(ident)
        end

        def x_clients_ensure_stop
          @x_clients and @x_clients.any? and @x_clients.values.each &:terminate
        end

        def x_focused_window_id
          Integer(`xdpyinfo`[/^focus:\s+window\s+(0x\h+)/, 1])
        end

        def x_input_event_masks
          `xdpyinfo`[/current input event mask:\s+0x\h+([\w\s]+):/, 1]
            .split(/\s+/)
            .grep /Mask\z/
        end

        def x_key *k, delay: 12
          k = k.join " key --delay #{delay} "
          fail "cannot simulate X key `#{k}'" unless system "xdotool key #{k}"
        end

        def x_window_map_state window_selector
          select_args = case window_selector
            when Integer  then "-id #{window_selector}"
            when String   then "-name #{window_selector}"
            else fail ArgumentError,
              "not an Integer nor a String: `#{window_selector.inspect}'"
          end
          `xwininfo #{select_args} 2> /dev/null`[/Map State: (\w+)/, 1]
        end


        private

        def timeout_until message = 'condition not met after %d seconds'
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
          fail TimeoutError.new(message % timeout, timeout)
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
            @window ||= @display.create_window(@geo).tap { |o| o.name = @name }
          end

          def window_id
            @window.id
          end

          def window_name
            @name
          end

          def window_name= name
            @name = window.name = name
            window.name
          end

          def map times: 1
            times.times { window.map }
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
