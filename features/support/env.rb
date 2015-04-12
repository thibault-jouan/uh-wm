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

Around '@other_wm_running' do |scenario, block|
  @other_wm = ChildProcess.build('twm')
  @other_wm.start
  block.call
  @other_wm.stop
end
