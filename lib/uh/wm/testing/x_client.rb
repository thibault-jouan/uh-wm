require 'uh'

module Uh
  module WM
    module Testing
      class XClient
        attr_reader :name

        def initialize name = object_id
          @name     = "#{self.class.name.split('::').last}/#{name}"
          @geo      = Geo.new(0, 0, 640, 480)
          @display  = Display.new.tap &:open
        end

        def terminate
          @display.close
        end

        def sync
          @display.sync false
          self
        end

        def window
          @window ||= @display.create_window(@geo).tap { |o| o.name = @name }
        end

        def window_id
          @window.id
        end

        def window_name
          @name
        end

        def window_name= name
          @name = window.name = name
          window.name
        end

        def window_class= wclass
          window.wclass = [wclass] * 2
        end

        def map times: 1
          times.times { window.map }
          window.map
          self
        end

        def unmap
          window.unmap
          self
        end

        def destroy
          window.destroy
          self
        end
      end
    end
  end
end
