module Uh
  module WM
    RSpec.describe Manager do
      subject(:manager) { described_class.new }

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
    end
  end
end
