module Uh
  module WM
    class Client
      attr_reader   :window
      attr_accessor :geo, :unmap_count

      def initialize window, geo = nil
        @window       = window
        @geo          = geo
        @visible      = false
        @unmap_count  = 0
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

      def update_window_properties
        @wname  = @window.name
        @wclass = @window.wclass
      end

      def configure
        @window.configure @geo
        self
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

      def hide
        @window.unmap
        @visible = false
        @unmap_count += 1
        self
      end

      def focus
        @window.raise
        @window.focus
        self
      end
    end
  end
end
