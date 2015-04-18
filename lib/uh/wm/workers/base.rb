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

        %w[before_wait on_timeout on_read on_read_next].each do |m|
          class_eval <<-eoh
            def #{m} &block
              if block_given? then @#{m} = block else @#{m} end
            end
          eoh
        end
      end
    end
  end
end
