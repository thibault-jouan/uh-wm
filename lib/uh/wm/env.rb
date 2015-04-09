module Uh
  module WM
    class Env
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
    end
  end
end
