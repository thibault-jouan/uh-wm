module Uh
  module WM
    module Workers
      class KQueue < Base
        TIMEOUT_DEFAULT = 1

        def initialize timeout: TIMEOUT_DEFAULT
          super
          @queue = ::KQueue::Queue.new
        end

        def watch io
          @queue.watch_stream_for_read io.to_io do
            @on_read.call
          end
        end

        def on_timeout &block
          ::KQueue::Watcher.new(@queue, 1, :timer, [], 1000, proc do |event|
            block.call
          end)
        end

        def work_events
          @before_watch.call if @before_watch
          events = @queue.process
        end
      end
    end
  end
end
