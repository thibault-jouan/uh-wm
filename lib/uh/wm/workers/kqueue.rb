module Uh
  module WM
    module Workers
      class KQueue < Base
        def initialize **options
          super
          @queue = ::KQueue::Queue.new
        end

        def watch io
          @queue.watch_stream_for_read io.to_io do
            @on_read.call
          end
        end

        def work_events
          @before_watch.call if @before_watch
          events = @queue.process
        end
      end
    end
  end
end
