require 'uh'

require 'uh/wm/cli'
require 'uh/wm/env'

module Uh
  module WM
    Error         = Class.new(StandardError)
    RuntimeError  = Class.new(RuntimeError)
    ArgumentError = Class.new(Error)
  end
end
