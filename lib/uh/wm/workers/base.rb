module Uh
  module WM
    module Workers
      class Base
        def initialize **options
          @ios = []
        end

        def watch io
          @ios << io
        end

        def before_wait &block
          if block_given? then @before_wait = block else @before_wait end
        end

        def on_timeout &block
          if block_given? then @on_timeout = block else @on_timeout end
        end

        def on_read &block
          if block_given? then @on_read = block else @on_read end
        end

        def on_read_next &block
          if block_given? then @on_read_next = block else @on_read_next end
        end
      end
    end
  end
end
