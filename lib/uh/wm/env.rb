require 'logger'

module Uh
  module WM
    class Env
      attr_reader :output, :logger

      def initialize output, logger_: Logger.new(output)
        @output = output
        @logger = logger_
      end

      def log message
        logger.info message
      end

      def print message
        @output.print message
      end
    end
  end
end
