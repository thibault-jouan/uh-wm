module Uh
  module WM
    module Workers
      class Blocking < Base
        def work_events
          @on_read_next.call
        end
      end
    end
  end
end
