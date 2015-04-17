module Uh
  module WM
    class Env
      RC_PATH = '~/.uhwmrc.rb'.freeze

      MODIFIER  = :mod1
      KEYBINDS  = {
        q: proc { quit }
      }.freeze
      WORKER    = :block

      LOGGER_LEVEL          = Logger::WARN
      LOGGER_LEVEL_VERBOSE  = Logger::INFO
      LOGGER_LEVEL_DEBUG    = Logger::DEBUG
      LOGGER_LEVEL_STRINGS  = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

      extend Forwardable
      def_delegator :logger, :info,   :log
      def_delegator :logger, :error,  :log_error
      def_delegator :logger, :debug,  :log_debug
      def_delegator :@output, :print

      attr_reader   :output, :keybinds
      attr_accessor :verbose, :debug, :rc_path, :layout_class, :modifier,
                    :worker

      def initialize output
        @output   = output
        @rc_path  = RC_PATH
        @modifier = MODIFIER
        @keybinds = KEYBINDS.dup
        @worker   = :block
      end

      def verbose?
        !!@verbose
      end

      def debug?
        !!@debug
      end

      def layout
        @layout ||= if layout_class
          layout_class.new
        else
          require 'uh/layout'
          ::Uh::Layout.new
        end
      end

      def logger
        @logger ||= Logger.new(@output).tap do |o|
          o.level = debug? ? LOGGER_LEVEL_DEBUG :
            verbose? ? LOGGER_LEVEL_VERBOSE :
            LOGGER_LEVEL
          o.formatter = LoggerFormatter.new
        end
      end

      def log_logger_level
        log "Logging at #{LOGGER_LEVEL_STRINGS[logger.level]} level"
      end
    end
  end
end
