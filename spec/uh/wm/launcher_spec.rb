module Uh
  module WM
    RSpec.describe Launcher do
      let(:actions)       { double 'actions', some_action: :some_action_code }
      let(:rules)         { { /some_rule/ => -> { :some_rule_code } } }
      let(:run_until)     { double 'run_until block', call: nil }
      subject(:launcher)  { described_class.new actions, rules, run_until }

      describe '#launch' do
        it 'delegates calls in given block to the actions handler' do
          expect(actions).to receive :some_action
          launcher.launch proc { some_action }
        end

        context 'execute! message' do
          before { allow(actions).to receive :execute }

          it 'delegates to #execute in the actions handler' do
            expect(actions).to receive(:execute).with :some_command
            launcher.launch proc { execute! :some_command }
          end

          it 'calls the run_until block' do
            expect(run_until).to receive :call
            launcher.launch proc { execute! :some_command }
          end

          it 'preserves the rules' do
            expect { launcher.launch proc { execute! :some_command } }
              .not_to change { rules }
          end
        end
      end
    end
  end
end
