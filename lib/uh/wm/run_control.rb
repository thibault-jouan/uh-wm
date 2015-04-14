module Uh
  module WM
    class RunControl
      KEYSYM_TRANSLATIONS = {
        backspace:  :BackSpace,
        enter:      :Return,
        return:     :Return,
        tab:        :Tab
      }.freeze

      class << self
        def evaluate env
          rc_path = File.expand_path(env.rc_path)
          rc = new env
          rc.evaluate File.read(rc_path) if File.exist?(rc_path)
        end
      end

      def initialize env
        @env = env
      end

      def evaluate code
        instance_eval code
      end

      def key keysym, &block
        @env.keybinds[translate_keysym keysym] = block
      end


      private

      def translate_keysym keysym
        KEYSYM_TRANSLATIONS.key?(keysym) ? KEYSYM_TRANSLATIONS[keysym] : keysym
      end
    end
  end
end
