Given /^another window manager is running$/ do
  expect(other_wm).to be_alive
end

Given /^uhwm is running$/ do
  uhwm_run_wait_ready
end

Given /^uhwm is running with options? (-.+)$/ do |options|
  uhwm_run_wait_ready options
end

Given /^uhwm is running with this run control file:$/ do |rc|
  write_file '.uhwmrc.rb', rc
  uhwm_run_wait_ready
end

When /^I quit uhwm$/ do
  uhwm_request_quit
  program_run_check status: 0
end
