module Uh
  module WM
    class Dispatcher
      attr_reader :hooks

      def initialize hooks = Hash.new
        @hooks = hooks
      end

      def [] *key
        @hooks[translate_key key] or []
      end

      def on *key, &block
        @hooks[translate_key key] ||= []
        @hooks[translate_key key] << block
      end


      private

      def translate_key key
        key.one? ? key[0] : key
      end
    end
  end
end
