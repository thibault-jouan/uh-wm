module Uh
  module WM
    module EnvLogging
      extend Forwardable
      def_delegators :@env, :log, :log_fatal, :log_error, :log_debug
    end
  end
end
