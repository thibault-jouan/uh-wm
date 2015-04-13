require 'aruba/cucumber'
require 'headless'

require 'uh/wm/testing/acceptance_helpers'

module Aruba
  class SpawnProcess
    def pid
      @process.pid
    end
  end
end

World(Uh::WM::Testing::AcceptanceHelpers)

Headless.new.start

After do |scenario|
  uhwm_ensure_stop
end

Around '@other_wm_running' do |scenario, block|
  with_other_wm { block.call }
end
