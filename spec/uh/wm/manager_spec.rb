module Uh
  module WM
    RSpec.describe Manager do
      let(:events)      { Dispatcher.new }
      let(:display)     { Display.new }
      subject(:manager) { described_class.new events, display }

      describe '#initialize' do
        it 'assigns a new display' do
          expect(manager.display).to be_a Display
        end
      end

      describe '#connect' do
        it 'opens the display' do
          expect(manager.display).to receive :open
          manager.connect
        end
      end

      describe '#grab_key' do
        it 'grabs given key on the display' do
          expect(manager.display)
            .to receive(:grab_key).with('q', KEY_MODIFIERS[:mod1])
          manager.grab_key :q
        end
      end

      describe '#handle_pending_events' do
        let(:event) { double 'event' }

        context 'when an event is pending on display' do
          before do
            allow(display).to receive(:pending?).and_return true, false
            allow(display).to receive(:next_event) { event }
          end

          it 'handles the event' do
            expect(manager).to receive(:handle).with(event).once
            manager.handle_pending_events
          end
        end

        context 'when multiple events are pending on display' do
          before do
            allow(display).to receive(:pending?).and_return true, true, false
            allow(display).to receive(:next_event) { event }
          end

          it 'handles all pending events' do
            expect(manager).to receive(:handle).with(event).twice
            manager.handle_pending_events
          end
        end
      end

      describe '#handle' do
        it 'handles an event'
      end
    end
  end
end
