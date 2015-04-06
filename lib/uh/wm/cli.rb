module Uh
  module WM
    class CLI
      class << self
        def run! arguments
          $stdout.sync = true
          @display = Display.new
          @display.open
          puts "Connected to X server on `#{display}'"
          sleep 8
        end
      end
    end
  end
end
