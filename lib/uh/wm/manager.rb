module Uh
  module WM
    class Manager
      attr_reader :display

      def initialize display = Display.new
        @display = display
      end

      def connect
        @display.open
      end

      def grab_key keysym
        @display.grab_key keysym.to_s, KEY_MODIFIERS[:mod1]
      end
    end
  end
end
