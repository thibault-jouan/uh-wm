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
    end
  end
end
