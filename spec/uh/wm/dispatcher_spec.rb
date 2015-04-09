module Uh
  module WM
    RSpec.describe Dispatcher do
      subject(:dispatcher)  { described_class.new }

      describe '#[]' do
        context 'when given key for existing hook' do
          before { dispatcher.hooks[:hook_key] = [:hook] }

          it 'returns registered hooks for this key' do
            expect(dispatcher[:hook_key]).to eq [:hook]
          end
        end

        context 'when given multiple keys for existing hook' do
          before { dispatcher.hooks[%i[hook key]] = [:hook] }

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

      describe '#emit' do
        it 'calls hooks registered for given key' do
          dispatcher.on(:hook_key) { throw :hook_code }
          expect { dispatcher.emit :hook_key }.to throw_symbol :hook_code
        end

        context 'when no hooks are registered for given key' do
          it 'does not call another hook' do
            dispatcher.on(:hook_key) { throw :hook_code }
            expect { dispatcher.emit :other_hook_key }.not_to throw_symbol
          end
        end

        context 'when no hooks are registered at all' do
          it 'does not raise any error' do
            expect { dispatcher.emit :hook_key }.not_to raise_error
          end
        end
      end
    end
  end
end
