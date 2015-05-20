module Uh
  module WM
    module Workers
      FACTORIES = {
        block:  ->(options) { Blocking.new(options) },
        kqueue: ->(options) { KQueue.new(options) },
        mux:    ->(options) { Mux.new(options) }
      }.freeze

      class << self
        def types
          FACTORIES.keys
        end

        def build type, **options
          (FACTORIES[type] or fail ArgumentError, "unknown worker: `#{type}'")
            .call options
        end
      end
    end
  end
end
