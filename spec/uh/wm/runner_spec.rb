module Uh
  module WM
    RSpec.describe Runner do
      let(:env)         { Env.new(StringIO.new) }
      subject(:runner)  { described_class.new env }

      describe '.run' do
        subject(:run) { described_class.run env, stopped: true }

        before do
          allow(Display)
            .to receive(:new) { double('display', open: nil).as_null_object }
        end

        it 'builds a new Runner with given env' do
          expect(described_class)
            .to receive(:new).with(env, anything).and_call_original
          run
        end

        it 'registers event hooks' do
          runner.stop!
          allow(described_class).to receive(:new) { runner }
          expect(runner).to receive(:register_event_hooks)
          run
        end

        it 'connects the manager' do
          runner.stop!
          allow(described_class).to receive(:new) { runner }
          expect(runner).to receive(:connect_manager)
          run
        end
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

      describe '#register_event_hooks' do
        context 'manager' do
          it 'registers manager event hooks' do
            runner.register_event_hooks
            expect(runner.events[:display, :connecting]).not_to be_empty
            expect(runner.events[:display, :connected]).not_to be_empty
          end
        end

        context 'key bindings' do
          it 'registers key bindings event hooks' do
            runner.register_event_hooks
            expect(runner.events[:key, :q]).not_to be_empty
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

        it 'tells the manager to grab keys' do
          expect(runner.manager).to receive(:grab_key).with :q
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
