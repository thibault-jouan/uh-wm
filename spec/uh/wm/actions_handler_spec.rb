module Uh
  module WM
    RSpec.describe ActionsHandler do
      let(:env)         { Env.new(StringIO.new) }
      let(:events)      { Dispatcher.new }
      subject(:actions) { described_class.new env, events }

      describe '#evaluate' do
        it 'evaluates given code' do
          expect { actions.evaluate proc { throw :action_code } }
            .to throw_symbol :action_code
        end
      end

      describe '#quit' do
        it 'emits the quit event' do
          expect(events).to receive(:emit).with :quit
          actions.quit
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
