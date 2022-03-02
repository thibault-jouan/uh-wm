require 'baf/testing/process'

require 'uh'
require 'uh/wm/testing/x_client'

module Uh
  module WM
    module Testing
      module AcceptanceHelpers
        QUIT_KEYBINDING = 'alt+shift+q'.freeze
        LOG_READY       = 'Working events'.freeze

        attr_reader :other_wm

        def icccm_window_start
          @icccm_window = Baf::Testing::Process.new %w[xmessage window],
            env_allow: %w[DISPLAY]
          @icccm_window.start
        end

        def icccm_window_ensure_stop
          @icccm_window.stop
        end

        def icccm_window_name
          'xmessage'
        end

        def uhwm_request_quit
          x_key QUIT_KEYBINDING
        end

        def uhwm_ensure_stop
          uhwm_request_quit
        end

        def uhwm_run_wait_ready options = '-v'
          cmd = $_baf[:program] + options.split(' ')
          env = Baf::Testing::ENV_WHITELIST + $_baf[:env_allow]
          Baf::Testing::Process.new(cmd, env_allow: env).tap do |uhwm|
            uhwm.start
            Baf::Testing.wait_output LOG_READY, stream: -> { uhwm.output }
          end
        end

        def with_other_wm uhwm_command
          env = Baf::Testing::ENV_WHITELIST + $_baf[:env_allow]
          @other_wm = Baf::Testing::Process.new uhwm_command, env_allow: env
          @other_wm.start
          yield
          uhwm_request_quit
          @other_wm = nil
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
      end
    end
  end
end
