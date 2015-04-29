module Uh
  module WM
    RSpec.describe Client do
      let(:protocols)   { [] }
      let(:window)      { mock_window icccm_wm_protocols: protocols }
      let(:geo)         { build_geo }
      subject(:client)  { described_class.new window, geo }

      it 'is not visible' do
        expect(client).not_to be_visible
      end

      it 'is hidden' do
        expect(client).to be_hidden
      end

      it 'has an unmap count of 0' do
        expect(client.unmap_count).to eq 0
      end

      describe '#to_s' do
        it 'includes window name' do
          expect(client.to_s).to include 'wname'
        end

        it 'includes window class' do
          expect(client.to_s).to include 'wclass'
        end

        it 'includes geo' do
          expect(client.to_s).to include geo.to_s
        end

        it 'includes window string representation' do
          expect(client.to_s).to include 'wid'
        end
      end

      describe '#name' do
        it 'returns the window name' do
          expect(client.name).to eq window.name
        end
      end

      describe '#wclass' do
        it 'returns the window class' do
          expect(client.wclass).to eq window.wclass
        end
      end

      describe '#update_window_properties' do
        it 'updates the cached window name' do
          client.name
          allow(window).to receive(:name) { 'new name' }
          expect { client.update_window_properties }
            .to change { client.name }
            .from('wname').to 'new name'
        end

        it 'updates the cached window class' do
          client.wclass
          allow(window).to receive(:wclass) { 'new class' }
          expect { client.update_window_properties }
            .to change { client.wclass }
            .from('wclass').to 'new class'
        end
      end

      describe '#configure' do
        it 'configures the window with client geo' do
          expect(window).to receive(:configure).with geo
          client.configure
        end

        it 'returns self' do
          expect(client.configure).to be client
        end
      end

      describe '#moveresize' do
        it 'moveresizes the window with client geo' do
          expect(window).to receive(:moveresize).with geo
          client.moveresize
        end

        it 'returns self' do
          expect(client.moveresize).to be client
        end
      end

      describe '#show' do
        it 'maps the window' do
          expect(window).to receive :map
          client.show
        end

        it 'toggles the client as visible' do
          expect { client.show }
            .to change { client.visible? }
            .from(false).to true
        end

        it 'returns self' do
          expect(client.show).to be client
        end
      end

      describe '#hide' do
        it 'unmaps the window' do
          expect(window).to receive :unmap
          client.hide
        end

        it 'toggles the client as hidden' do
          client.show
          expect { client.hide }
            .to change { client.hidden? }
            .from(false).to true
        end

        it 'increments the unmap count' do
          expect { client.hide }
            .to change { client.unmap_count }
            .from(0).to 1
        end

        it 'returns self' do
          expect(client.hide).to be client
        end
      end

      describe '#focus' do
        it 'raises the window' do
          expect(window).to receive :raise
          client.focus
        end

        it 'focuses the window' do
          expect(window).to receive :focus
          client.focus
        end

        it 'returns self' do
          expect(client.focus).to be client
        end
      end

      describe '#kill' do
        it 'kills the window' do
          expect(window).to receive :kill
          client.kill
        end

        it 'returns self' do
          expect(client.kill).to be client
        end

        context 'when window supports icccm wm delete' do
          let(:protocols) { [:WM_DELETE_WINDOW] }

          it 'icccm deletes the window' do
            expect(window).to receive :icccm_wm_delete
            client.kill
          end
        end
      end

      describe '#kill!' do
        it 'kills the window' do
          expect(window).to receive :kill
          client.kill!
        end

        it 'returns self' do
          expect(client.kill!).to be client
        end
      end
    end
  end
end
