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

        def uhwm_wait_output message, timeout: 1
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
          @other_wm = ChildProcess.build('twm').tap { |o| o.start }
          @other_wm.stop
        end

        def other_wm
          @other_wm
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
          'Event Tester'
        end

        def x_window_map
          spawn 'xev -event owner_grab_button'
        end
      end
    end
  end
end
