module Uh
  module WM
    class Runner
      include EnvLogging

      class << self
        def run env, **options
          runner = new env, **options
          runner.evaluate_run_control
          runner.register_event_hooks
          runner.connect_manager
          runner.run_until { runner.stopped? }
          runner.terminate
        end
      end

      extend Forwardable
      def_delegator :@env, :layout

      attr_reader :env, :events, :actions, :rules

      def initialize env, manager: nil, stopped: false
        @env      = env
        @events   = Dispatcher.new
        @manager  = manager
        @actions  = ActionsHandler.new(@env, @events)
        @stopped  = stopped
        @rules    = @env.rules
      end

      def stopped?
        !!@stopped
      end

      def stop!
        @stopped = true
      end

      def manager
        @manager ||= Manager.new(@events, @env.modifier)
      end

      def evaluate_run_control
        RunControl.evaluate(env)
      end

      def register_event_hooks
        %w[runner manager layout keybinds rules launcher]
          .map  { |e| "register_#{e}_hooks".to_sym }
          .each { |e| send e }
      end

      def connect_manager
        manager.connect
        @env.keybinds.each { |keysym, _| manager.grab_key *keysym }
      end

      def worker
        @worker ||= Workers.build(*(@env.worker)).tap do |w|
          w.before_watch  { @manager.handle_pending_events }
          w.on_read       { @manager.handle_pending_events }
          w.on_read_next  { @manager.handle_next_event }
          w.on_timeout do |*args|
            log_debug "Worker timeout: #{args.inspect}"
            log_debug 'Flushing X output buffer'
            @manager.flush
          end
        end
      end

      def run_until &block
        worker.watch @manager
        log "Working events with `#{worker.class}'"
        worker.work_events until block.call
      end

      def terminate
        log 'Terminating...'
        manager.disconnect
      end


      private

      def register_runner_hooks
        @events.on(:quit) { stop! }
      end

      def register_manager_hooks
        @events.on :connecting do |display|
          log_debug "Connecting to X server on `#{display}'"
        end
        @events.on :connected do |display|
          log "Connected to X server on `#{display}'"
        end
        @events.on(:disconnected) { log 'Disconnected from X server' }
        @events.on(:xevent) { |event| XEventLogger.new(env).log_event event }
        @events.on(:xerror) do |*error|
          if error.none?
            log_fatal 'Fatal X IO Error received'
          else
            XEventLogger.new(env).log_xerror *error
          end
        end
      end

      def register_layout_hooks
        @events.on :connected do |display|
          log "Registering layout `#{layout.class}'"
          layout.register display
        end
        @events.on :configure do |window|
          log "Configuring window: #{window}"
          layout.suggest_geo
        end
        @events.on :manage do |client|
          log "Managing client #{client}"
          layout << client
        end
        @events.on :unmanage do |client|
          log "Unmanaging client #{client}"
          layout.remove client
        end
        @events.on :change do |client|
          log "Updating client #{client}"
          layout.update client
        end
        @events.on :expose do |window|
          log "Exposing window: #{window}"
          layout.expose window
        end
      end

      def register_keybinds_hooks
        @env.keybinds.each do |keysym, code|
          @events.on(:key, *keysym) { @actions.evaluate code }
        end
      end

      def register_rules_hooks
        @events.on :manage do |client|
          @rules.each do |selector, code|
            @actions.evaluate code if client.wclass =~ selector
          end
        end
      end

      def register_launcher_hooks
        @events.on :connected do
          Launcher.launch(self, @env.launch) if @env.launch
        end
      end


      class XEventLogger
        include EnvLogging

        def initialize env
          @env = env
        end

        def log_event xev
          complement = case xev.type
          when :key_press
            "window: #{xev.window} key: #{xev.key} mask: #{xev.modifier_mask}"
          when :map_request
            "window: #{xev.window}"
          end

          log_debug [
            'XEvent',
            xev.type,
            xev.send_event ? 'SENT' : nil,
            complement
          ].compact.join ' '
        end

        def log_xerror req, resource_id, msg
          log_error "XERROR: #{resource_id} #{req} #{msg}"
        end
      end
    end
  end
end
