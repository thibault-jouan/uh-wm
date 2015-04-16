module Uh
  module WM
    RSpec.describe Client do
      let(:geo)         { Geo.new(0, 0, 640, 480) }
      let(:window) do
        instance_spy Window, 'window', to_s: 'wid',
          name: 'wname', wclass: 'wclass'
      end
      subject(:client)  { described_class.new window, geo }

      it 'is not visible' do
        expect(client).not_to be_visible
      end

      it 'is hidden' do
        expect(client).to be_hidden
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

        it 'includes window id' do
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

      describe '#moveresize' do
        it 'moveresizes the window with client geo' do
          expect(window).to receive(:moveresize).with geo
          client.moveresize
        end

        it 'returns self' do
          expect(client.moveresize).to be client
        end
      end
    end
  end
end
