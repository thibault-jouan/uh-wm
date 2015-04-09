module Uh
  module WM
    RSpec.describe Env do
      let(:output)  { StringIO.new }
      let(:logger)  { Logger.new(StringIO.new) }
      subject(:env) { described_class.new output, logger: logger }

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
