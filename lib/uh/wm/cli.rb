module Uh
  module WM
    class CLI
      ArgumentError = Class.new(ArgumentError)

      USAGE = "Usage: #{File.basename $0} [options]".freeze

      EX_USAGE = 64

      class << self
        def run arguments, stdout: $stdout, stderr: $stderr
          cli = new arguments, stdout: stdout
          cli.parse_arguments!
          cli.run
        rescue ArgumentError => e
          stderr.puts e
          exit EX_USAGE
        end
      end

      attr_reader :env

      def initialize args, stdout: $stdout
        @arguments  = args
        @env        = Env.new(stdout.tap { |o| o.sync = true })
      end

      def parse_arguments!
        option_parser.parse! @arguments
      rescue OptionParser::InvalidOption => e
        fail ArgumentError, option_parser
      end

      def run
        Runner.run env
      end


      private

      def option_parser
        OptionParser.new do |opts|
          opts.banner = USAGE
          opts.separator ''
          opts.separator 'options:'

          opts.on '-h', '--help', 'print this message' do
            @env.print opts
            exit
          end
        end
      end
    end
  end
end
