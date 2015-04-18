module Uh
  module WM
    module Workers
      class Base
        CALLBACKS = %w[before_wait on_timeout on_read on_read_next].freeze

        def initialize **options
          @ios = []
        end

        def watch io
          @ios << io
        end

        CALLBACKS.each do |m|
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
