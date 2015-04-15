SomeLayout = Class.new do
  define_method(:register) { |*args| }
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

      describe '#initialize' do
        it 'assigns the env' do
          expect(runner.env).to be env
        end

        it 'assigns a new Dispatcher' do
          expect(runner.events).to be_a Dispatcher
        end

        it 'assigns a new Manager' do
          expect(runner.manager).to be_a Manager
        end

        it 'is not stopped' do
          expect(runner).not_to be_stopped
        end
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

      describe '#evaluate_run_control' do
        it 'evaluates the run control file with RunControl and current env' do
          expect(RunControl).to receive(:evaluate).with env
          runner.evaluate_run_control
        end
      end

      describe '#register_event_hooks' do
        it 'registers manager event hooks for logging' do
          runner.register_event_hooks
          expect(env).to receive(:log)
          runner.events.emit :connected
        end

        it 'registers layout hook for :connected event' do
          runner.register_event_hooks
          expect(env.layout).to receive(:register).with :display
          runner.events.emit :connected, args: :display
        end

        it 'registers key bindings event hooks' do
          env.keybinds[:f] = -> { }
          runner.register_event_hooks
          expect(runner.events[:key, :f]).not_to be_empty
        end

        it 'registers combined key bindings event hooks' do
          env.keybinds[[:f, :shift]] = -> { }
          runner.register_event_hooks
          expect(runner.events[:key, :f, :shift]).not_to be_empty
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

      describe '#run_until' do
        it 'tells the manager to handle events until given block is true' do
          block = proc { }
          allow(block).to receive(:call).and_return(false, false, false, true)
          expect(runner.manager).to receive(:handle_pending_events).exactly(3).times
          runner.run_until &block
        end
      end
    end
  end
end
