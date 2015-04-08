module Uh
  module WM
    RSpec.describe Dispatcher do
      let(:hooks)           { {} }
      subject(:dispatcher)  { described_class.new hooks }

      describe '#[]' do
        context 'when given key for existing hook' do
          let(:hooks) { { hook_key: [:hook] } }

          it 'returns registered hooks for this key' do
            expect(dispatcher[:hook_key]).to eq [:hook]
          end
        end

        context 'when given multiple keys for existing hook' do
          let(:hooks) { { %i[hook key] => [:hook] } }

          it 'returns registered hooks for this key' do
            expect(dispatcher[:hook, :key]).to eq [:hook]
          end
        end

        context 'when given key for unknown hook' do
          it 'returns an empty array' do
            expect(dispatcher[:unknown_hook]).to eq []
          end
        end
      end

      describe '#on' do
        it 'registers given hook for given key' do
          dispatcher.on(:hook_key) { :hook }
          expect(dispatcher.hooks[:hook_key]).to be
        end

        it 'registers given hook for given multiple keys' do
          dispatcher.on(:hook, :key) { :hook }
          expect(dispatcher.hooks[%i[hook key]]).to be
        end
      end
    end
  end
end
