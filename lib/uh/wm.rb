require 'forwardable'
require 'logger'
require 'optparse'
require 'rbconfig'
require 'uh'

require 'uh/wm/env_logging'

require 'uh/wm/actions_handler'
require 'uh/wm/cli'
require 'uh/wm/client'
require 'uh/wm/dispatcher'
require 'uh/wm/env'
require 'uh/wm/launcher'
require 'uh/wm/logger_formatter'
require 'uh/wm/manager'
require 'uh/wm/run_control'
require 'uh/wm/runner'
require 'uh/wm/version'
require 'uh/wm/workers'
require 'uh/wm/workers/base'
require 'uh/wm/workers/blocking'
require 'uh/wm/workers/kqueue' unless RbConfig::CONFIG['host_os'] =~ /linux/i
require 'uh/wm/workers/mux'

module Uh
  module WM
    Error                     = Class.new(StandardError)
    RuntimeError              = Class.new(RuntimeError)
    ArgumentError             = Class.new(Error)
    RunControlEvaluationError = Class.new(RuntimeError)

    class OtherWMRunningError < RuntimeError
      def message
        'another window manager is already running'
      end
    end
  end
end
