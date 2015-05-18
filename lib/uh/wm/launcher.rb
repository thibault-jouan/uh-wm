module Uh
  module WM
    class Launcher
      class << self
        def launch runner, instructions
          new(runner.actions, runner.rules, runner.method(:run_until))
            .launch instructions
        end
      end

      def initialize actions, rules, run_until
        @actions    = actions
        @rules      = rules
        @run_until  = run_until
      end

      def launch instructions
        with_clean_rules do
          rules = @rules
          DSL.new(@actions).evaluate(instructions).each do |m, args, block|
            if m == :execute!
              @rules[//] = -> { rules.clear }
              @actions.execute *args, &block
              @run_until.call { @rules.empty? }
            else
              @actions.send m, *args, &block
            end
          end
        end
      end


      private

      def with_clean_rules
        original_rules = @rules.dup
        @rules.clear
        yield
        @rules.clear
        @rules.merge! original_rules
      end


      class DSL
        def initialize actions
          @actions  = actions
          @messages = []
        end

        def evaluate instructions
          instance_eval &instructions
          self
        end

        def each
          @messages.each { |m| yield *m }
        end

        def method_missing m, *args, &block
          if respond_to? m
            @messages << [m, args, block]
          else
            super
          end
        end

        def respond_to_missing? m, _
          m == :execute! || @actions.respond_to?(m) || super
        end
      end
    end
  end
end
