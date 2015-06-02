SomeLayout = Class.new do
  include Factories

  define_method(:initialize)  { |*_| }
  define_method(:register)    { |*_| }
  define_method(:suggest_geo) { build_geo 0, 0, 42, 42 }
  define_method(:<<)          { |*_| }
  define_method(:remove)      { |*_| }
  define_method(:update)      { |*_| }
end

module Uh
  module WM
    RSpec.describe Runner do
      let(:env)         { Env.new(StringIO.new) }
      subject(:runner)  { described_class.new env }

      before do
        env.layout_class  = SomeLayout
        env.rc_path       = 'non_existent_run_control.rb'
      end

      it 'has a dispatcher' do
        expect(runner.events).to be_a Dispatcher
      end

      it 'is not stopped' do
        expect(runner).not_to be_stopped
      end

      describe '#stopped?' do
        context 'when not stopped' do
          it 'returns false' do
            expect(runner.stopped?).to be false
          end
        end

        context 'when stopped' do
          before { runner.stop! }

          it 'returns true' do
            expect(runner.stopped?).to be true
          end
        end
      end

      describe '#stop!' do
        it 'sets the runner as stopped' do
          expect { runner.stop! }
            .to change { runner.stopped? }
            .from(false).to(true)
        end
      end

      describe '#manager' do
        it 'returns the manager' do
          expect(runner.manager).to be_a Manager
        end

        it 'sets the manager modifier as env modifier' do
          expect(runner.manager.modifier).to eq env.modifier
        end

        it 'sets the manager modifier ignore as env modifier ignore ' do
          expect(runner.manager.modifier_ignore).to eq env.modifier_ignore
        end
      end

      describe '#evaluate_run_control' do
        it 'evaluates the run control file with RunControl and current env' do
          expect(RunControl).to receive(:evaluate).with env
          runner.evaluate_run_control
        end
      end

      describe '#register_event_hooks' do
        it 'registers quit event hook' do
          runner.register_event_hooks
          expect(runner).to receive :stop!
          runner.events.emit :quit
        end

        context 'layout hooks' do
          it 'registers for :connected event' do
            runner.register_event_hooks
            expect(env.layout).to receive(:register).with :display
            runner.events.emit :connected, args: :display
          end

          it 'registers for :configure event' do
            runner.register_event_hooks
            expect(runner.events.emit :configure, args: :window)
              .to eq build_geo 0, 0, 42, 42
          end

          it 'registers for :manage event' do
            runner.register_event_hooks
            expect(env.layout).to receive(:<<).with :client
            runner.events.emit :manage, args: :client
          end

          it 'registers for :unmanage event' do
            runner.register_event_hooks
            expect(env.layout).to receive(:remove).with :client
            runner.events.emit :unmanage, args: :client
          end

          it 'registers for :change event' do
            runner.register_event_hooks
            expect(env.layout).to receive(:update).with :client
            runner.events.emit :change, args: :client
          end

          it 'registers for :tick event' do
            runner.register_event_hooks
            expect(env.layout).to receive(:update)
            runner.events.emit :tick
          end
        end

        context 'keys hooks' do
          it 'registers for :key' do
            env.keybinds[:f] = -> { }
            runner.register_event_hooks
            expect(runner.events[:key, :f]).not_to be_empty
          end

          it 'registers for :key with combined key bindings' do
            env.keybinds[[:f, :shift]] = -> { }
            runner.register_event_hooks
            expect(runner.events[:key, :f, :shift]).not_to be_empty
          end

          it 'registers code evaluation with the actions handler' do
            env.keybinds[:f] = code = proc { }
            runner.register_event_hooks
            expect(runner.actions).to receive(:evaluate).with code
            runner.events.emit :key, :f
          end
        end

        context 'rules hooks' do
          let(:client) { double 'client', wclass: 'some_client_class' }

          it 'registers rule code evaluation with the actions handler' do
            env.rules[/#{client.wclass}/] = code = proc { }
            runner.register_event_hooks
            expect(runner.actions).to receive(:evaluate).with code
            runner.events.emit :manage, args: client
          end
        end

        context 'launcher hooks' do
          let(:client) { double 'client', wclass: 'some_client_class' }

          it 'registers launcher execution' do
            env.launch = -> { :launch_code }
            runner.register_event_hooks
            expect(Launcher).to receive(:launch).with(runner, env.launch)
            runner.events.emit :connected
          end
        end
      end

      describe '#connect_manager' do
        let(:manager)     { instance_spy Manager }
        subject(:runner)  { described_class.new env, manager: manager }

        it 'connects the manager' do
          expect(runner.manager).to receive :connect
          runner.connect_manager
        end

        it 'tells the manager to grab keys for env key bindings' do
          env.keybinds[:f] = -> { }
          expect(runner.manager).to receive(:grab_key).with :f
          runner.connect_manager
        end
      end

      describe '#worker' do
        let(:manager)     { instance_spy Manager }
        subject(:runner)  { described_class.new env, manager: manager }

        it 'returns a worker' do
          expect(runner.worker).to respond_to :work_events
        end

        it 'setups the before_watch callback' do
          expect(runner.manager).to receive :flush
          runner.worker.before_watch.call
        end

        it 'setups the read callback' do
          expect(runner.manager).to receive :handle_pending_events
          runner.worker.on_read.call
        end

        it 'setups the read_next callback' do
          expect(runner.manager).to receive :handle_next_event
          runner.worker.on_read_next.call
        end

        it 'setups the timeout callback to emit :tick event' do
          expect(runner.events).to receive(:emit).with :tick
          runner.worker.on_timeout.call
        end

        it 'setups the timeout callback to flush manager' do
          expect(runner.manager).to receive :flush
          runner.worker.on_timeout.call
        end
      end

      describe '#run_until' do
        let(:manager)     { instance_spy Manager }
        subject(:runner)  { described_class.new env, manager: manager }

        it 'tells the worker to watch the manager' do
          expect(runner.worker).to receive(:watch).with runner.manager
          runner.run_until { true }
        end

        it 'tells the worker to work events until given block is true' do
          block = proc { }
          allow(block).to receive(:call).and_return(false, false, false, true)
          expect(runner.worker).to receive(:work_events).exactly(3).times
          runner.run_until &block
        end
      end

      describe '#terminate' do
        it 'tells the manager to disconnect' do
          expect(runner.manager).to receive :disconnect
          runner.terminate
        end
      end
    end
  end
end
