module Uh
  module WM
    class CLI < Baf::CLI
      class << self
        def handle_error env, ex
          env.puts_error "#{ex.class.name}: #{ex.message}"
          env.puts_error ex.backtrace.map { |l| '  %s' % l } if env.debug?
        end
      end

      def setup
        flag_verbose
        flag_debug
        flag_version WM::VERSION

        option :f, :run_control, 'PATH', 'specify alternate run control file' do |path|
          @env.rc_path = path
        end
        option :r, :require, 'PATH', 'require ruby feature' do |feature|
          require feature
          env.log "Loaded `#{feature}' ruby feature"
        end
        option :l, :layout, 'LAYOUT', 'specify layout' do |layout|
          env.layout_class = Object.const_get layout.to_sym
        end
        option :w, :worker, 'WORKER', 'specify worker' do |worker|
          env.worker = worker.to_sym
        end

        env.sync_output
      end

      def run
        env.log_logger_level
        Runner.run env
      end
    end
  end
end
