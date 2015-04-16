require 'uh'

module Uh
  module WM
    module Testing
      module AcceptanceHelpers
        def uhwm_run options = '-v'
          command = %w[uhwm]
          command << options if options
          @interactive = @process = run command.join ' '
        end

        def uhwm_ensure_stop
          @process and @process.terminate
        end

        def uhwm_pid
          @process.pid
        end

        def uhwm_output
          @process.stdout
        end

        def uhwm_wait_output message
          timeout = ENV.key?('UHWMTEST_OUTPUT_TIMEOUT') ?
            ENV['UHWMTEST_OUTPUT_TIMEOUT'].to_i :
            1
          Timeout.timeout(timeout) do
            loop do
              break if case message
                when Regexp then @process.stdout + @process.stderr =~ message
                when String then assert_partial_output_interactive message
              end
              sleep 0.1
            end
          end
        rescue Timeout::Error
          output = (@process.stdout + @process.stderr).lines
            .map { |e| "  #{e}" }
            .join
          fail [
            "expected `#{message}' not seen after #{timeout} seconds in:",
            "  ```\n#{output}  ```"
          ].join "\n"
        end

        def uhwm_run_wait_ready options = nil
          if options then uhwm_run options else uhwm_run end
          uhwm_wait_output 'Connected to'
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

        def x_client
          @x_client ||= XClient.new
        end

        def x_key key
          fail "cannot simulate X key `#{key}'" unless system "xdotool key #{key}"
        end

        def x_socket_check pid
          case RbConfig::CONFIG['host_os']
          when /linux/
            `netstat -xp 2> /dev/null`.lines.grep /\s+#{pid}\/ruby/
          else
            `sockstat -u`.lines.grep /\s+ruby.+\s+#{pid}/
          end.any?
        end

        def x_window_name
          @x_client.window_name
        end

        def x_window_map
          x_client.map.sync
        end

        def x_clients_ensure_stop
          @x_client and @x_client.terminate
        end


        private

        class XClient
          attr_reader :name

          def initialize
            @name     = "#{self.class.name.split('::').last}/#{object_id}"
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

          def window_name
            @name
          end

          def map
            window.map
            self
          end
        end
      end
    end
  end
end
