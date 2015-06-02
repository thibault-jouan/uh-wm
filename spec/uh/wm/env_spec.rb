module Uh
  module WM
    RSpec.describe Env do
      let(:output)  { StringIO.new }
      let(:logger)  { Logger.new(StringIO.new) }
      subject(:env) { described_class.new output }

      it 'has verbose mode disabled' do
        expect(env).not_to be_verbose
      end

      it 'has debug mode disabled' do
        expect(env).not_to be_debug
      end

      it 'has the default rc path set' do
        expect(env.rc_path).to eq '~/.uhwmrc.rb'
      end

      it 'has no layout_class set' do
        expect(env.layout_class).not_to be
      end

      it 'has the default modifier set' do
        expect(env.modifier).to eq :mod1
      end

      it 'has no ignored modifiers' do
        expect(env.modifier_ignore).to be_empty
      end

      it 'has default key binding for quit set' do
        expect(env.keybinds.keys).to include [:q, :shift]
      end

      it 'has the blocking worker by default' do
        expect(env.worker).to eq :block
      end

      it 'has no rules' do
        expect(env.rules).to be_empty
      end

      it 'has no launch code' do
        expect(env.launch).to be nil
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

      describe '#debug?' do
        context 'when debug mode is disabled' do
          before { env.debug = false }

          it 'returns false' do
            expect(env.debug?).to be false
          end
        end

        context 'when debug mode is enabled' do
          before { env.debug = true }

          it 'returns true' do
            expect(env.debug?).to be true
          end
        end
      end

      describe '#layout' do
        let(:some_layout_class) { Class.new { def initialize **_; end } }

        it 'returns the default layout' do
          expect(env.layout).to be_an_instance_of ::Uh::Layout
        end

        it 'instantiates the default layout with layout_options' do
          env.layout_options[:colors] = { foo: :bar }
          expect(env.layout.colors[:foo]).to eq :bar
        end

        context 'when a layout is set' do
          let(:some_layout) { some_layout_class.new }

          before { env.layout = some_layout }

          it 'returns the assigned layout' do
            expect(env.layout).to be some_layout
          end
        end

        context 'when a layout class is set' do
          before { env.layout_class = some_layout_class }

          it 'returns a new instance of this layout class' do
            expect(env.layout).to be_an_instance_of some_layout_class
          end

          it 'instantiates the layout class with layout_options' do
            env.layout_options[:foo] = :bar
            expect(some_layout_class).to receive(:new).with(foo: :bar)
            env.layout
          end
        end
      end

      describe '#logger' do
        it 'returns a logger' do
          expect(env.logger).to be_a Logger
        end

        it 'has logger level warn set' do
          expect(env.logger.level).to be Logger::WARN
        end

        context 'when verbose mode is enabled' do
          before { env.verbose = true }

          it 'has logger level info set' do
            expect(env.logger.level).to be Logger::INFO
          end
        end

        context 'when debug mode is enabled' do
          before { env.debug = true }

          it 'has logger level debug set' do
            expect(env.logger.level).to be Logger::DEBUG
          end
        end
      end

      describe '#log' do
        it 'logs given message at info level' do
          expect(env.logger).to receive(:info).with 'some message'
          env.log 'some message'
        end
      end

      describe '#log_debug' do
        it 'logs given message at debug level' do
          expect(env.logger).to receive(:debug).with 'some message'
          env.log_debug 'some message'
        end
      end

      describe '#log_logger_level' do
        it 'logs the logger level' do
          expect(env.logger)
            .to receive(:info).with /log.+(warn|info|debug).+level/i
          env.log_logger_level
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
