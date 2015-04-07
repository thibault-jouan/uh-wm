require 'support/exit_helpers'

module Uh
  module WM
    RSpec.describe CLI do
      include ExitHelpers

      let(:stdout)    { StringIO.new }
      let(:stderr)    { StringIO.new }
      let(:arguments) { [] }
      let(:options)   { { stdout: stdout, stderr: stderr } }

      subject(:cli)   { described_class.new arguments, **options }

      describe '.run' do
        subject(:run) { described_class.run arguments, **options }

        it 'builds a new CLI with given arguments' do
          expect(described_class)
            .to receive(:new).with(arguments, options).and_call_original
          run
        end

        it 'parses new CLI arguments' do
          cli = instance_spy CLI
          allow(described_class).to receive(:new) { cli }
          expect(cli).to receive :parse_arguments!
          run
        end

        it 'runs new CLI' do
          cli = instance_spy CLI
          allow(described_class).to receive(:new) { cli }
          expect(cli).to receive :run
          run
        end

        context 'with invalid arguments' do
          let(:arguments) { %w[--unknown-option] }

          it 'prints the usage' do
            expect { trap_exit { run } }.to output(/\AUsage: .+/).to_stderr
          end

          it 'exits with a return status of 64' do
            stderr_original = $stderr
            $stderr = stderr
            expect { run }.to raise_error(SystemExit) do |e|
              expect(e.status).to eq 64
            end
            $stderr = stderr_original
          end
        end
      end

      describe '#run' do
        let(:display) { instance_spy Display }

        before { allow(Display).to receive(:new) { display } }

        it 'opens a new X display' do
          expect(display).to receive :open
          cli.run
        end

        it 'prints a message on standard output when connected' do
          cli.run
          expect(stdout.string).to match /connected/i
        end
      end

      describe '#parse_arguments!' do
        context 'with help option' do
          let(:arguments) { %w[-h] }

          it 'prints the usage banner on standard output' do
            trap_exit { cli.parse_arguments! }
            expect(stdout.string).to match /\AUsage: .+/
          end

          it 'prints options usage on standard output' do
            trap_exit { cli.parse_arguments! }
            expect(stdout.string).to match /\n^options:\n\s+-/
          end
        end

        context 'with invalid option' do
          let(:arguments) { %w[--unknown-option] }

          it 'raises a CLI::ArgumentError' do
            expect { cli.parse_arguments! }
              .to raise_error CLI::ArgumentError
          end
        end
      end
    end
  end
end
