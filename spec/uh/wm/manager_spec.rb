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

      describe '#connect', :xvfb do
        let(:block) { proc { } }

        it 'opens the display' do
          expect(manager.display).to receive(:open).and_call_original
          manager.connect
        end

        it 'emits :connecting event with the display' do
          events.on :connecting, &block
          expect(block).to receive(:call) do |*args|
            expect(args).to eq [display]
          end
          manager.connect
        end

        it 'emits :connected event with the display' do
          events.on :connected, &block
          expect(block).to receive(:call) do |*args|
            expect(args).to eq [display]
          end
          manager.connect
        end

        context 'when connection fails' do
          before { allow(display).to receive(:open) { fail } }

          it 'does not emit :connected event' do
            events.on :connected, &block
            expect(block).not_to receive :call
            manager.connect rescue nil
          end
        end
      end

      describe '#grab_key' do
        it 'grabs given key on the display' do
          expect(manager.display)
            .to receive(:grab_key).with('f', KEY_MODIFIERS[:mod1])
          manager.grab_key :f
        end

        context 'when a modifier is given' do
          it 'grabs the key with given modifier' do
            expect(manager.display)
              .to receive(:grab_key)
              .with('f', KEY_MODIFIERS[:mod1] | KEY_MODIFIERS[:shift])
            manager.grab_key :f, :shift
          end
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
        context 'when key_press event is given' do
          let(:mod_mask) { KEY_MODIFIERS[:mod1] }
          let(:event) do
            double 'event',
              type:           :key_press,
              key:            'f',
              modifier_mask:  mod_mask
          end

          it 'emits :key event with the corresponding key' do
            events.on(:key, :f) { throw :key_press_code }
            expect { manager.handle event }.to throw_symbol :key_press_code
          end

          context 'whith shift key modifier' do
            let(:mod_mask) { KEY_MODIFIERS[:mod1] | KEY_MODIFIERS[:shift] }

            it 'emits :key event with the corresponding key and :shift' do
              events.on(:key, :f, :shift) { throw :key_press_code }
              expect { manager.handle event }.to throw_symbol :key_press_code
            end
          end
        end
      end
    end
  end
end
