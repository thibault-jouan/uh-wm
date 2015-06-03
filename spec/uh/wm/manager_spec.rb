module Uh
  module WM
    RSpec.describe Manager do
      let(:block)       { proc { } }
      let(:window)      { mock_window }
      let(:client)      { build_client window }
      let(:events)      { Dispatcher.new }
      let(:modifier)    { :mod1 }
      let(:display)     { Display.new }
      subject(:manager) { described_class.new events, modifier, [], display }

      it 'has no clients' do
        expect(manager.clients).to be_empty
      end

      describe '#to_io' do
        context 'when connected' do
          before { allow(display).to receive(:fileno) { 1 } }

          it 'returns an IO object wrapping the display file descriptor' do
            expect(manager.to_io)
              .to be_an(IO)
              .and have_attributes(fileno: display.fileno)
          end
        end
      end

      describe '#connect' do
        let(:display) { double('display').as_null_object }

        it 'opens the display' do
          expect(manager.display).to receive(:open)
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

        it 'updates the root window mask in order to manage windows', :xvfb do
          manager = described_class.new events,
            modifier, [], display = Display.new
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

        context 'when some modifiers are ignored' do
          subject :manager do
            described_class.new events, modifier, %i[mod2 mod5], display
          end

          it 'grabs the key with all masks combining ignored modifiers' do
            [
              [modifier],
              [modifier, :mod2],
              [modifier, :mod5],
              [modifier, :mod2, :mod5]
            ].each do |mods|
              mod_mask = mods.map { |e| KEY_MODIFIERS[e] }.inject &:|
              expect(manager.display).to receive(:grab_key).with'f', mod_mask
            end
            manager.grab_key :f
          end
        end
      end

      describe '#configure' do
        context 'with new window' do
          it 'sends a configure event to the window with a default geo' do
            expect(window)
              .to receive(:configure_event).with(build_geo 0, 0, 320, 240)
            manager.configure window
          end

          context 'when :configure event returns a geo' do
            it 'sends a configure event with geo returned by event' do
              geo = build_geo 0, 0, 42, 42
              events.on(:configure) { geo }
              expect(window).to receive(:configure_event).with geo
              manager.configure window
            end
          end
        end

        context 'with known window' do
          before { manager.clients << client }

          it 'tells the client to configure' do
            expect(client).to receive :configure
            manager.configure window
          end
        end
      end

      describe '#map' do
        let(:display) { instance_spy Display }

        it 'registers a new client wrapping the given window' do
          manager.map window
          expect(manager.clients[0])
            .to be_a(Client)
            .and have_attributes(window: window)
        end

        it 'registers new client only once for a given window' do
          manager.map window
          expect { manager.map window }.not_to change { manager.clients }
        end

        it 'ignores event when window has override redirect' do
          allow(window).to receive(:override_redirect?) { true }
          expect { manager.map window }.not_to change { manager.clients }
        end

        it 'emits :manage event with the registered client' do
          events.on :manage, &block
          expect(block).to receive :call do |client|
            expect(client)
              .to be_a(Client)
              .and have_attributes(window: window)
          end
          manager.map window
        end

        it 'listens for property notify events on given window' do
          expect(display)
            .to receive(:listen_events)
            .with window, Events::PROPERTY_CHANGE_MASK
          manager.map window
        end
      end

      describe '#unmap' do
        before { manager.clients << client }

        context 'when client unmap count is 0 or less' do
          it 'preserves the client unmap count' do
            expect { manager.unmap window }.not_to change { client.unmap_count }
          end

          it 'unregisters the client' do
            manager.unmap window
            expect(manager.clients).not_to include client
          end

          it 'emits :unmanage event with the client' do
            events.on :unmanage, &block
            expect(block).to receive(:call).with client
            manager.unmap window
          end
        end

        context 'when client unmap count is strictly positive' do
          before { client.unmap_count += 1 }

          it 'does not unregister the client' do
            manager.unmap window
            expect(manager.clients).to include client
          end

          it 'decrements the unmap count' do
            manager.unmap window
            expect(client.unmap_count).to eq 0
          end
        end

        context 'with unknown window' do
          let(:unknown_window) { window.dup }

          it 'does not change registered clients' do
            expect { manager.unmap unknown_window }
              .not_to change { manager.clients }
          end

          it 'does not emit any event' do
            expect(events).not_to receive :emit
            manager.unmap unknown_window
          end
        end
      end

      describe '#destroy' do
        before { manager.clients << client }

        it 'unregisters the client' do
          manager.destroy window
          expect(manager.clients).not_to include client
        end

        it 'emits :unmanage event with the client' do
          events.on :unmanage, &block
          expect(block).to receive(:call).with client
          manager.destroy window
        end

        context 'with unknown window' do
          let(:unknown_window) { window.dup }

          it 'does not change registered clients' do
            expect { manager.destroy unknown_window }
              .not_to change { manager.clients }
          end

          it 'does not emit any event' do
            expect(events).not_to receive :emit
            manager.destroy unknown_window
          end
        end
      end

      describe '#update_properties' do
        context 'with known window' do
          before { manager.clients << client }

          it 'tells the client to update its window properties' do
            expect(client).to receive :update_window_properties
            manager.update_properties window
          end

          it 'emits :change event with the client' do
            events.on :change, &block
            expect(block).to receive(:call).with client
            manager.update_properties window
          end
        end

        context 'with unknown window' do
          it 'does not emit any event' do
            expect(events).not_to receive :emit
            manager.update_properties window
          end
        end
      end

      describe '#handle_next_event' do
        it 'handles the next available event on display' do
          event = double 'event'
          allow(display).to receive(:next_event) { event }
          expect(manager).to receive(:handle).with(event).once
          manager.handle_next_event
        end
      end

      describe '#handle_pending_events' do
        let(:event) { mock_event }

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
        let(:event) { mock_event }

        it 'emits :xevent event with the X event' do
          events.on :xevent, &block
          manager.handle event
        end

        context 'when key_press event is given' do
          let(:mod_mask)  { KEY_MODIFIERS[modifier] }
          let(:event)     { mock_event_key_press 'f', mod_mask }

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

          context 'with an ignored modifier' do
            let(:mod_mask) { KEY_MODIFIERS[modifier] | KEY_MODIFIERS[:mod2] }
            subject :manager do
              described_class.new events, modifier, %i[mod2 mod5], display
            end

            it 'emits :key event with the corresponding key' do
              events.on(:key, :f) { throw :key_press_code }
              expect { manager.handle event }.to throw_symbol :key_press_code
            end
          end
        end

        context 'when configure request event is given' do
          let(:event) { mock_event :configure_request, window: :window }

          it 'configures the event window' do
            expect(manager).to receive(:configure).with :window
            manager.handle event
          end
        end

        context 'when destroy_notify event is given' do
          let(:event) { mock_event :destroy_notify, window: :window }

          it 'destroy the event window' do
            expect(manager).to receive(:destroy).with :window
            manager.handle event
          end
        end

        context 'when map_request event is given' do
          let(:event) { mock_event :map_request, window: :window }

          it 'maps the event window' do
            expect(manager).to receive(:map).with :window
            manager.handle event
          end
        end

        context 'when unmap_notify event is given' do
          let(:event) { mock_event :unmap_notify, window: :window }

          it 'unmaps the event window' do
            expect(manager).to receive(:unmap).with :window
            manager.handle event
          end
        end

        context 'when property_notify event is given' do
          let(:event) { mock_event :property_notify, window: :window }

          it 'updates event window properties' do
            expect(manager).to receive(:update_properties).with :window
            manager.handle event
          end
        end
      end
    end
  end
end
