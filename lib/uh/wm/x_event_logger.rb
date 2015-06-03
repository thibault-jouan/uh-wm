module Uh
  module WM
    class XEventLogger
      include EnvLogging

      def initialize env
        @env = env
      end

      def log_event xev
        complement = case xev.type
        when :key_press
          "window: #{xev.window} key: #{xev.key} mask: #{xev.modifier_mask}"
        when :map_request
          "window: #{xev.window}"
        end

        log_debug [
          'XEvent',
          xev.type,
          xev.send_event ? 'SENT' : nil,
          complement
        ].compact.join ' '
      end

      def log_xerror req, resource_id, msg
        log_error "XERROR: #{resource_id} #{req} #{msg}"
      end
    end
  end
end
