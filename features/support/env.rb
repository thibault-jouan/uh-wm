require 'aruba/cucumber'
require 'headless'

module Aruba
  class SpawnProcess
    def pid
      @process.pid
    end
  end
end

Headless.new.start

After do |scenario|
  @process and @process.terminate
end
