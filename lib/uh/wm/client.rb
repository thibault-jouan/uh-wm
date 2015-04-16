module Uh
  module WM
    class Client
      attr_reader   :window
      attr_accessor :geo

      def initialize window, geo = nil
        @window   = window
        @geo      = geo
        @visible  = false
      end

      def to_s
        "<#{name}> (#{wclass}) #{@geo} win: #{@window}"
      end

      def visible?
        @visible
      end

      def hidden?
        not visible?
      end

      def name
        @wname ||= @window.name
      end

      def wclass
        @wclass ||= @window.wclass
      end

      def moveresize
        @window.moveresize @geo
        self
      end

      def show
        @window.map
        @visible = true
        self
      end
    end
  end
end
