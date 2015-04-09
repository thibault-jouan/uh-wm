module Uh
  module WM
    class Manager
      attr_reader :display

      def initialize events, display = Display.new
        @events   = events
        @display  = display
      end

      def connect
        @events.emit :display, :connecting, args: @display
        @display.open
        @events.emit :display, :connected, args: @display
      end

      def grab_key keysym
        @display.grab_key keysym.to_s, KEY_MODIFIERS[:mod1]
      end

      def handle_pending_events
        handle @display.next_event while @display.pending?
      end

      def handle event
        case event.type
        when :key_press then @events.emit :key, event.key.to_sym
        end
      end
    end
  end
end
