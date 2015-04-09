module Uh
  module WM
    RSpec.describe Env do
      let(:output)  { StringIO.new }
      let(:logger)  { Logger.new(StringIO.new) }
      subject(:env) { described_class.new output, logger: logger }

      it 'has verbose mode disabled' do
        expect(env).not_to be_verbose
      end

      describe '#verbose?' do
        context 'when verbose mode is disabled' do
          before { env.verbose = false }

          it 'returns false' do
            expect(env.verbose?).to be false
          end
        end

        context 'when verbose mode is enabled' do
          before { env.verbose = true }

          it 'returns true' do
            expect(env.verbose?).to be true
          end
        end
      end

      describe '#logger' do
        it 'returns a logger' do
          expect(env.logger).to be_a ::Logger
        end
      end

      describe '#log' do
        it 'logs given message at info level' do
          expect(logger).to receive(:info).with 'some message'
          env.log 'some message'
        end
      end

      describe '#print' do
        it 'prints the message to the output' do
          env.print 'some message'
          expect(output.string).to eq 'some message'
        end
      end
    end
  end
end
