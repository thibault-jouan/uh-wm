module Uh
  module WM
    module Workers
      class Base
        CALLBACKS = %w[before_watch on_timeout on_read on_read_next].freeze

        def initialize **options
          @ios = []
        end

        def watch io
          @ios << io.to_io
        end

        CALLBACKS.each do |m|
          define_method m do |*_, &block|
            if block
              instance_variable_set "@#{m}".to_sym, block
            else
              instance_variable_get "@#{m}".to_sym
            end
          end
        end
      end
    end
  end
end
