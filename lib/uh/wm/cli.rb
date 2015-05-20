module Uh
  module WM
    class CLI
      ArgumentError = Class.new(ArgumentError)

      include EnvLogging

      USAGE = "Usage: #{File.basename $0} [options]".freeze

      EX_USAGE    = 64
      EX_SOFTWARE = 70

      class << self
        def run arguments, stdout: $stdout, stderr: $stderr
          cli = new arguments, stdout: stdout
          cli.parse_arguments!
          cli.run
        rescue ArgumentError => e
          stderr.puts e
          exit EX_USAGE
        rescue RuntimeError => e
          stderr.puts "#{e.class.name}: #{e.message}"
          stderr.puts e.backtrace.map { |e| '  %s' % e } if cli.env.debug?
          exit EX_SOFTWARE
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
        raise ArgumentError, option_parser
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

          opts.on '-v', '--verbose', 'enable verbose mode' do
            @env.verbose = true
            @env.log_logger_level
          end
          opts.on '-d', '--debug', 'enable debug mode' do
            @env.debug = true
            @env.log_logger_level
          end
          opts.on '-f', '--run-control PATH',
              'specify alternate run control file' do |e|
            @env.rc_path = e
          end
          opts.on '-r', '--require PATH', 'require ruby feature' do |feature|
            require feature
            log "Loaded `#{feature}' ruby feature"
          end
          opts.on '-l', '--layout LAYOUT', 'specify layout' do |layout|
            @env.layout_class = Object.const_get layout.to_sym
          end
          opts.on '-w', Workers.types, '--worker WORKER',
              'specify worker' do |worker|
            @env.worker = worker.to_sym
          end

          opts.separator ''
          opts.on_tail '-h', '--help', 'print this message' do
            @env.print opts
            exit
          end
          opts.on_tail '-V', '--version', 'print version' do
            @env.puts WM::VERSION
            exit
          end
        end
      end
    end
  end
end
