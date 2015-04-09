module Uh
  module WM
    class Env
      extend Forwardable
      def_delegator :@logger, :info, :log
      def_delegator :@output, :print

      attr_reader :output, :logger

      def initialize output, logger_: Logger.new(output)
        @output = output
        @logger = logger_
      end
    end
  end
end
