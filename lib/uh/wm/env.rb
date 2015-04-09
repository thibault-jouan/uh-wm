module Uh
  module WM
    class Env
      extend Forwardable
      def_delegator :@logger, :info, :log
      def_delegator :@output, :print

      attr_reader :output, :logger

      def initialize output, logger: Logger.new(output)
        @output = output
        @logger = logger
      end
    end
  end
end
