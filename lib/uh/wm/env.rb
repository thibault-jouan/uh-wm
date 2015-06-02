module Uh
  module WM
    class Env
      RC_PATH = '~/.uhwmrc.rb'.freeze

      MODIFIER  = :mod1
      KEYBINDS  = {
        [:q, :shift] => proc { quit }
      }.freeze
      WORKER    = :block

      LOGGER_LEVEL          = Logger::WARN
      LOGGER_LEVEL_VERBOSE  = Logger::INFO
      LOGGER_LEVEL_DEBUG    = Logger::DEBUG
      LOGGER_LEVEL_STRINGS  = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

      extend Forwardable
      def_delegator   :logger, :info,   :log
      def_delegator   :logger, :fatal,  :log_fatal
      def_delegator   :logger, :error,  :log_error
      def_delegator   :logger, :debug,  :log_debug
      def_delegators  :@output, :print, :puts

      attr_reader   :output, :keybinds
      attr_accessor :verbose, :debug, :rc_path, :modifier, :worker,
                    :layout, :layout_class, :layout_options, :rules, :launch

      def initialize output
        @output         = output
        @rc_path        = RC_PATH
        @modifier       = MODIFIER
        @keybinds       = KEYBINDS.dup
        @layout_options = {}
        @worker         = WORKER
        @rules          = {}
      end

      def verbose?
        !!@verbose
      end

      def debug?
        !!@debug
      end

      def layout
        @layout ||= if layout_class
          layout_class.new @layout_options
        else
          require 'uh/layout'
          ::Uh::Layout.new(@layout_options)
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
