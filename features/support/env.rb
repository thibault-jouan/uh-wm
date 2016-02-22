Before do
  @_baf_program = 'uhwm'.freeze
end

require 'baf/testing/cucumber'
require 'baf/testing/cucumber/steps/output_wait'

require 'uh/wm/testing/acceptance_helpers'
require 'uh/wm/testing/headless'

World(Uh::WM::Testing::AcceptanceHelpers)
World(Uh::WM::Testing::Headless)

unless ENV.key? 'UHWMTEST_CI'
  Around do |_, block|
    with_xvfb do
      block.call
    end
  end
end

Before do
  set_environment_variable 'HOME', expand_path(?.)
  set_environment_variable 'DISPLAY', ':42' unless ENV.key? 'UHWMTEST_CI'
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
