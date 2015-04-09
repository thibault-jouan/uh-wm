module Uh
  module WM
    class Env
      LOGGER_LEVEL          = Logger::WARN
      LOGGER_LEVEL_VERBOSE  = Logger::INFO
      LOGGER_LEVEL_STRINGS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]

      extend Forwardable
      def_delegator :logger, :info, :log
      def_delegator :@output, :print

      attr_reader   :output
      attr_accessor :verbose, :debug

      def initialize output
        @output = output
      end

      def verbose?
        !!@verbose
      end

      def debug?
        !!@debug
      end

      def logger
        @logger ||= Logger.new(@output).tap do |o|
          o.level = verbose? ? LOGGER_LEVEL_VERBOSE : LOGGER_LEVEL
        end
      end

      def log_logger_level
        log "Logging at #{LOGGER_LEVEL_STRINGS[logger.level]} level"
      end
    end
  end
end
