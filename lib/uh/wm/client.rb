module Uh
  module WM
    class Client
      attr_reader :window

      def initialize window, geo = nil
        @window = window
        @geo    = geo
      end

      def to_s
        "<#{wname}> (#{wclass}) #{@geo} win: #{@window}"
      end

      def wname
        @wname ||= @window.name
      end

      def wclass
        @wclass ||= @window.wclass
      end
    end
  end
end
