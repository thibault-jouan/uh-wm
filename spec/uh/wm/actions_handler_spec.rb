module Uh
  module WM
    RSpec.describe ActionsHandler do
      let(:env)         { build_env output: StringIO.new }
      let(:events)      { Dispatcher.new }
      subject(:actions) { described_class.new env, events }

      describe '#evaluate' do
        it 'evaluates code given as Proc argument' do
          expect { actions.evaluate proc { throw :action_code } }
            .to throw_symbol :action_code
        end

        it 'evaluates code given as block' do
          expect { actions.evaluate { throw :action_code } }
            .to throw_symbol :action_code
        end
      end

      describe '#quit' do
        it 'emits the quit event' do
          expect(events).to receive(:emit).with :quit
          actions.quit
        end
      end

      describe '#kill_current' do
        let(:client) { instance_spy Client }

        context 'when layout has a client' do
          before do
            allow(actions.layout).to receive(:current_client) { client }
          end

          it 'kills layout current client' do
            expect(client).to receive :kill
            actions.kill_current
          end
        end
      end

      describe '#log_separator' do
        it 'logs a separator' do
          expect(env).to receive(:log).with /(?:- ){20,}/
          actions.log_separator
        end
      end

      describe '#layout_*' do
        it 'delegates messages to the layout with handle_ prefix' do
          expect(env.layout).to receive :handle_screen_sel
          actions.layout_screen_sel :succ
        end
      end
    end
  end
end
