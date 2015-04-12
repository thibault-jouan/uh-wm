module Uh
  module WM
    class Manager
      INPUT_MASK = Events::SUBSTRUCTURE_REDIRECT_MASK

      attr_reader :display

      def initialize events, display = Display.new
        @events   = events
        @display  = display
      end

      def connect
        @events.emit :connecting, args: @display
        @display.open
        Display.on_error do
          fail OtherWMRunningError, 'another window manager is already running'
        end
        @display.listen_events INPUT_MASK
        @display.sync false
        Display.on_error { |*args| handle_error *args }
        @display.sync false
        @events.emit :connected, args: @display
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


      private

      def handle_error *args
        @dispatcher.emit :error, args: args
      end
    end
  end
end
