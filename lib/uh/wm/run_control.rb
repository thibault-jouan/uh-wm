module Uh
  module WM
    class RunControl
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
    end
  end
end
