module Uh
  module WM
    class Manager
      attr_reader :display

      def initialize events, display = Display.new
        @events   = events
        @display  = display
      end

      def connect
        @display.open
      end

      def grab_key keysym
        @display.grab_key keysym.to_s, KEY_MODIFIERS[:mod1]
      end

      def handle_pending_events
        handle @display.next_event while @display.pending?
      end

      def handle event
      end
    end
  end
end
