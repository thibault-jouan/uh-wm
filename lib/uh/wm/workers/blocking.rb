module Uh
  module WM
    module Workers
      class Blocking < Base
        def work_events
          #until yield
          #  @on_events_read_bang.call
          #end
          #@on_events_read_bang.call until yield
          @on_read_next.call
        end
      end
    end
  end
end
