module Uh
  module WM
    module Workers
      class Mux < Base
        def initialize timeout: 1
          super
          @timeout = timeout
        end

        def work_events
          @before_wait.call if @before_wait
          if res = select(@ios, [], [], @timeout) then @on_read.call res
          else @on_timeout.call if @on_timeout end
        end
      end
    end
  end
end
