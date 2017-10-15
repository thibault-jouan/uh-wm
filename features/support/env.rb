require 'aruba/cucumber'

require 'uh/wm/testing/acceptance_helpers'
require 'uh/wm/testing/headless'

module Aruba
  class SpawnProcess
    def pid
      @process.pid
    end
  end
end

World(Uh::WM::Testing::AcceptanceHelpers)
World(Uh::WM::Testing::Headless)

unless ENV.key? 'UHWMTEST_CI'
  ENV['DISPLAY'] = ':42'

  Around do |_, block|
    with_xvfb do
      block.call
    end
  end
end

Before do
  set_env 'HOME', File.expand_path(current_directory)
end

After do
  uhwm_ensure_stop
  x_clients_ensure_stop
end

Around '@other_wm_running' do |_, block|
  with_other_wm { block.call }
end

After '@icccm_window' do
  icccm_window_ensure_stop
end
