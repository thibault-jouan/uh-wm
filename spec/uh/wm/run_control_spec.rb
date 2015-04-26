require 'support/filesystem_helpers'

module Uh
  module WM
    RSpec.describe RunControl do
      include FileSystemHelpers

      let(:env)     { Env.new(StringIO.new) }
      subject(:rc)  { described_class.new env }

      describe '.evaluate' do
        around do |example|
          with_file ':run_control_code' do |f|
            env.rc_path = f.path
            example.run
          end
        end

        it 'builds a new instance with given env' do
          expect(described_class).to receive(:new).with(env).and_call_original
          described_class.evaluate env
        end

        it 'tells the new instance to evaluate run control file content' do
          expect(rc)
            .to receive(:evaluate).with(':run_control_code', env.rc_path)
          allow(described_class).to receive(:new) { rc }
          described_class.evaluate env
        end

        context 'when run control file is not present' do
          before { env.rc_path = 'non_existent_rc_file.rb' }

          it 'does not raise any error' do
            expect { described_class.evaluate env }.not_to raise_error
          end
        end
      end

      describe '#evaluate' do
        it 'evaluates given code' do
          expect { rc.evaluate 'throw :run_control_code', 'some_path' }
            .to throw_symbol :run_control_code
        end

        it 'provides access to assigned env' do
          expect { rc.evaluate 'fail @env.object_id.to_s', 'some_path' }
            .to raise_error env.object_id.to_s
        end
      end

      describe '#modifier' do
        it 'updates env modifier' do
          rc.modifier :ctrl
          expect(env.modifier).to eq :ctrl
        end
      end

      describe '#key' do
        let(:code) { -> { :keybind_code } }

        it 'registers a key binding in the env' do
          rc.key :f, &code
          expect(env.keybinds.keys).to include :f
        end

        it 'registers a combined keys binding in the env' do
          rc.key :f, :shift, &code
          expect(env.keybinds.keys).to include %i[f shift]
        end

        it 'registers given block with the key binding' do
          rc.key :f, &code
          expect(env.keybinds[:f].call).to eq :keybind_code
        end

        it 'translates common key names to equivalent X keysym' do
          rc.key :enter, &code
          expect(env.keybinds.keys).to include :Return
        end

        it 'translates upcased key name to a combination with shift' do
          rc.key :F, &code
          expect(env.keybinds.keys).to include %i[f shift]
        end
      end

      describe '#layout' do
        context 'when given a class' do
          it 'sets a layout class in the env' do
            rc.layout layout_class = Class.new
            expect(env.layout_class).to be layout_class
          end
        end

        context 'when given an object' do
          it 'sets a layout instance in the env' do
            rc.layout layout = Object.new
            expect(env.layout).to eq layout
          end
        end
      end

      describe '#worker' do
        it 'sets the worker type in the env' do
          rc.worker :some_worker
          expect(env.worker[0]).to eq :some_worker
        end

        it 'sets the worker options in the env' do
          rc.worker :some_worker, some: :option
          expect(env.worker[1]).to eq({ some: :option })
        end
      end
    end
  end
end
