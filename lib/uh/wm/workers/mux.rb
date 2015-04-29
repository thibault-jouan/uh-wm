module Uh
  module WM
    module Workers
      class Mux < Base
        TIMEOUT_DEFAULT = 1

        def initialize timeout: TIMEOUT_DEFAULT
          super
          @timeout = timeout
        end

        def work_events
          @before_watch.call if @before_watch
          if res = select(@ios, [], [], @timeout) then @on_read.call res
          else @on_timeout.call if @on_timeout end
        end
      end
    end
  end
end
