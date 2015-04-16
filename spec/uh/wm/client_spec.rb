module Uh
  module WM
    RSpec.describe Client do
      let(:geo)         { Geo.new(0, 0, 640, 480) }
      let(:window)      { double 'window', to_s: 'wid', name: 'wname', wclass: 'wclass' }
      subject(:client)  { described_class.new window, geo }

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

      describe '#wname' do
        it 'returns the window name' do
          expect(client.wname).to eq window.name
        end
      end

      describe '#wclass' do
        it 'returns the window class' do
          expect(client.wclass).to eq window.wclass
        end
      end
    end
  end
end
