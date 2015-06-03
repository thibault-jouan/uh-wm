module Uh
  module WM
    class Dispatcher
      attr_reader :hooks

      def initialize
        @hooks = Hash.new { |h, k| h[k] = [] }
      end

      def [] *key
        @hooks[translate_key key]
      end

      def on *key, &block
        @hooks[translate_key key] << block
      end

      def emit *key, args: []
        value = nil
        @hooks[translate_key key].each { |e| value = e.call *args }
        value
      end

    private

      def translate_key key
        key.one? ? key[0] : key
      end
    end
  end
end
