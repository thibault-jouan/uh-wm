module Uh
  module WM
    class CLI
      ArgumentError = Class.new(ArgumentError)

      USAGE = "Usage: #{File.basename $0} [options]".freeze

      EX_USAGE = 64

      class << self
        def run arguments, **options
          cli = new arguments, **options
          cli.parse_arguments!
          cli.run
        rescue ArgumentError => e
          $stderr.puts e
          exit EX_USAGE
        end
      end

      def initialize args, stdin: $stdin, stdout: $stdout, stderr: $stderr
        @arguments  = args
        @stdin      = stdin
        @stdout     = stdout
        @stderr     = stderr
      end

      def parse_arguments!
        option_parser.parse! @arguments
      rescue OptionParser::InvalidOption => e
        fail ArgumentError, option_parser
      end

      def run
        @stdout.sync = true
        @display = Display.new
        @display.open
        @stdout.puts "Connected to X server on `#{@display}'"
      end


      private

      def option_parser
        OptionParser.new do |opts|
          opts.banner = USAGE
          opts.separator ''
          opts.separator 'options:'

          opts.on '-h', '--help', 'print this message' do
            @stdout.print opts
            exit
          end
        end
      end
    end
  end
end
