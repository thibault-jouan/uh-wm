require 'uh'

require 'uh/wm/cli'
require 'uh/wm/env'
require 'uh/wm/manager'

module Uh
  module WM
    Error         = Class.new(StandardError)
    RuntimeError  = Class.new(RuntimeError)
    ArgumentError = Class.new(Error)
  end
end
