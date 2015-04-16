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

Before do
  set_env 'HOME', File.expand_path(current_dir)
end

After do
  uhwm_ensure_stop
  x_clients_ensure_stop
end

Around '@other_wm_running' do |_, block|
  with_other_wm { block.call }
end

if ENV.key? 'TRAVIS'
  ENV['UHWMTEST_OUTPUT_TIMEOUT'] = 8.to_s
end
