module Uh
  module WM
    class Client
      attr_reader   :window
      attr_accessor :geo

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

      def moveresize
        @window.moveresize @geo
        self
      end
    end
  end
end
