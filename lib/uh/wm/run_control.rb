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
          rc.evaluate File.read(rc_path), rc_path if File.exist?(rc_path)
        end
      end

      def initialize env
        @env = env
      end

      def evaluate code, path
        instance_eval code, path
      end

      def modifier mod
        @env.modifier = mod
      end

      def key *keysyms, &block
        @env.keybinds[translate_keysym *keysyms] = block
      end

      def layout obj
        if obj.is_a? Class
          @env.layout_class = obj
        else
          @env.layout = obj
        end
      end

      def worker type, **options
        @env.worker = [type, options]
      end


      private

      def translate_keysym keysym, modifier = nil
        return [translate_keysym(keysym)[0].to_sym, modifier] if modifier
        translate_key = keysym.to_s.downcase.to_sym
        translated_keysym = KEYSYM_TRANSLATIONS.key?(translate_key) ?
          KEYSYM_TRANSLATIONS[translate_key] :
          translate_key
        keysym =~ /[A-Z]/ ? [translated_keysym, :shift] : translated_keysym
      end
    end
  end
end
