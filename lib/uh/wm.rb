require 'forwardable'
require 'logger'
require 'optparse'
require 'uh'

require 'uh/wm/cli'
require 'uh/wm/dispatcher'
require 'uh/wm/env'
require 'uh/wm/manager'
require 'uh/wm/runner'

module Uh
  module WM
    Error               = Class.new(StandardError)
    RuntimeError        = Class.new(RuntimeError)
    ArgumentError       = Class.new(Error)

    class OtherWMRunningError < RuntimeError
      def message
        'another window manager is already running'
      end
    end
  end
end
