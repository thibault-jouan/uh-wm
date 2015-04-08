module Uh
  module WM
    class Manager
      attr_reader :display

      def initialize
        @display = Display.new
      end

      def connect
        @display.open
      end
    end
  end
end
