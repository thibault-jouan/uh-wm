module Uh
  module WM
    RSpec.describe Manager do
      let(:block)       { proc { } }
      let(:events)      { Dispatcher.new }
      let(:modifier)    { :mod1 }
      let(:display)     { Display.new }
      subject(:manager) { described_class.new events, modifier, display }

      it 'has a new display' do
        expect(manager.display).to be_a Display
      end

      it 'has no clients' do
        expect(manager.clients).to be_empty
      end

      describe '#to_io', :xvfb do
        context 'when connected' do
          before { manager.connect }

          it 'returns an IO object wrapping the display file descriptor' do
            expect(manager.to_io)
              .to be_an(IO)
              .and have_attributes(fileno: display.fileno)
          end
        end
      end

      describe '#connect', :xvfb do
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

        it 'updates the root window mask in order to manage windows' do
          manager.connect
          expect(display.root.mask).to eq Events::PROPERTY_CHANGE_MASK |
            Events::SUBSTRUCTURE_REDIRECT_MASK |
            Events::SUBSTRUCTURE_NOTIFY_MASK |
            Events::STRUCTURE_NOTIFY_MASK
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

      describe '#disconnect' do
        it 'closes the display' do
          expect(display).to receive :close
          manager.disconnect
        end

        it 'emits :disconnected event' do
          allow(display).to receive :close
          events.on :disconnected, &block
          expect(block).to receive :call
          manager.disconnect
        end
      end

      describe '#flush' do
        it 'flushes the display' do
          expect(display).to receive :flush
          manager.flush
        end
      end

      describe '#grab_key' do
        it 'grabs given key on the display' do
          expect(manager.display)
            .to receive(:grab_key).with('f', KEY_MODIFIERS[modifier])
          manager.grab_key :f
        end

        context 'when a modifier is given' do
          it 'grabs the key with given modifier' do
            expect(manager.display)
              .to receive(:grab_key)
              .with('f', KEY_MODIFIERS[modifier] | KEY_MODIFIERS[:shift])
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
        let(:event) { double 'event', type: :any }

        it 'emits :xevent event with the X event' do
          events.on :xevent, &block
          manager.handle event
        end

        context 'when key_press event is given' do
          let(:mod_mask) { KEY_MODIFIERS[modifier] }
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
            let(:mod_mask) { KEY_MODIFIERS[modifier] | KEY_MODIFIERS[:shift] }

            it 'emits :key event with the corresponding key and :shift' do
              events.on(:key, :f, :shift) { throw :key_press_code }
              expect { manager.handle event }.to throw_symbol :key_press_code
            end
          end
        end

        context 'when map_request event is given' do
          let(:event) { double 'event', type: :map_request, window: :window }

          it 'registers a new client wrapping the event window' do
            manager.handle event
            expect(manager.clients[0])
              .to be_a(Client)
              .and have_attributes(window: :window)
          end

          it 'emits :manage event with the registered client' do
            events.on :manage, &block
            expect(block).to receive :call do |client|
              expect(client)
                .to be_a(Client)
                .and have_attributes(window: :window)
            end
            manager.handle event
          end
        end
      end
    end
  end
end
