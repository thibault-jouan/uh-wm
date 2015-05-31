module Uh
  module WM
    module Workers
      class KQueue < Base
        TIMEOUT_DEFAULT = 1

        def initialize timeout: TIMEOUT_DEFAULT
          super
          @timeout = timeout * 1000
        end

        def work_events
          @before_watch.call if @before_watch
          queue.run
        end


        private

        def queue
          @queue ||= ::KQueue::Queue.new.tap do |q|
            @ios.each do |io|
              ::KQueue::Watcher.new(q, io.fileno, :read, [], nil, proc do |_|
                q.stop
                @on_read.call
              end)
            end
            ::KQueue::Watcher.new(q, 1, :timer, [], @timeout, proc do |_|
              q.stop
              @on_timeout.call
            end)
          end
        end
      end
    end
  end
end
