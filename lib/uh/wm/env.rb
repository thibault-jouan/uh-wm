module Uh
  module WM
    class Env
      LOGGER_LEVEL_STRINGS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]

      extend Forwardable
      def_delegator :@logger, :info, :log
      def_delegator :@output, :print

      attr_reader   :output, :logger
      attr_accessor :verbose

      def initialize output, logger: Logger.new(output)
        @output = output
        @logger = logger
      end

      def verbose?
        !!@verbose
      end

      def log_logger_level
        log "Logging at #{LOGGER_LEVEL_STRINGS[@logger.level]} level"
      end
    end
  end
end
