require 'support/exit_helpers'

module Uh
  module WM
    RSpec.describe CLI do
      include ExitHelpers

      let(:stdout)    { StringIO.new }
      let(:stderr)    { StringIO.new }
      let(:arguments) { [] }
      subject(:cli)   { described_class.new arguments, stdout: stdout }

      describe '.run' do
        subject(:run) do
          described_class.run arguments, stdout: stdout, stderr: stderr
        end

        # Prevent Runner from connecting a Manager and blocking.
        before { allow(Runner).to receive :run }

        it 'builds a new CLI with given arguments' do
          expect(described_class)
            .to receive(:new).with(arguments, stdout: stdout).and_call_original
          run
        end

        it 'parses new CLI arguments' do
          cli
          allow(described_class).to receive(:new) { cli }
          expect(cli).to receive :parse_arguments!
          run
        end

        it 'runs new CLI' do
          cli
          allow(described_class).to receive(:new) { cli }
          expect(cli).to receive :run
          run
        end

        context 'with invalid arguments' do
          let(:arguments) { %w[--unknown-option] }

          it 'prints the usage on standard error stream' do
            trap_exit { run }
            expect(stderr.string).to match /\AUsage: .+/
          end

          it 'exits with a return status of 64' do
            expect { run }.to raise_error(SystemExit) do |e|
              expect(e.status).to eq 64
            end
          end
        end
      end

      describe '#initialize' do
        it 'builds an env with given stdout' do
          expect(cli.env.output).to be stdout
        end

        it 'syncs the output' do
          expect(stdout).to receive(:sync=).with(true)
          cli
        end
      end

      describe '#run' do
        it 'runs a runner with the env' do
          expect(Runner).to receive(:run).with(cli.env)
          cli.run
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

        context 'with verbose option' do
          let(:arguments) { %w[-v] }

          it 'sets the env as verbose' do
            cli.parse_arguments!
            expect(cli.env).to be_verbose
          end

          it 'tells the env to log its logger level' do
            expect(cli.env).to receive :log_logger_level
            cli.parse_arguments!
          end
        end

        context 'with debug option' do
          let(:arguments) { %w[-d] }

          it 'sets the env as debug' do
            cli.parse_arguments!
            expect(cli.env).to be_debug
          end

          it 'tells the env to log its logger level' do
            expect(cli.env).to receive :log_logger_level
            cli.parse_arguments!
          end
        end

        context 'with require option' do
          let(:arguments) { %w[-r abbrev] }

          it 'requires the given ruby feature' do
            expect { cli.parse_arguments! }
              .to change { $LOADED_FEATURES.grep(/abbrev/).any? }
              .from(false).to(true)
          end

          it 'logs a message about the feature being loaded' do
            expect(cli.env).to receive(:log).with /load.+abbrev.+ruby feature/i
            cli.parse_arguments!
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
