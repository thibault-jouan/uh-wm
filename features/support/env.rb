require 'baf/testing'
require 'baf/testing/cucumber/steps/execution'
require 'baf/testing/cucumber/steps/filesystem'
require 'baf/testing/cucumber/steps/output'
require 'baf/testing/cucumber/steps/output_wait'

require 'uh/wm/testing/acceptance_helpers'
require 'uh/wm/testing/headless'

World(Uh::WM::Testing::AcceptanceHelpers)
World(Uh::WM::Testing::Headless)

ENV['DISPLAY'] = ':42'

$_baf = {
  program: [File.realpath('./bin/uhwm')],
  env_allow: %w[DISPLAY]
}

Around do |_, block|
  with_xvfb do
    Baf::Testing.exercise_scenario do
      begin
        block.call
      ensure
        uhwm_ensure_stop
        x_clients_ensure_stop
      end
    end
  end
  $_baf.delete :process
end

Around '@other_wm_running' do |_, block|
  with_other_wm($_baf[:program]) { block.call }
end

After '@icccm_window' do
  icccm_window_ensure_stop
end
