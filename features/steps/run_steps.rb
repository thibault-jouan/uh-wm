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

When /^I start uhwm$/ do
  uhwm_run
end

When /^I run uhwm with options? (-.+)$/ do |options|
  uhwm_run options
end

When /^I tell uhwm to quit$/ do
  uhwm_request_quit
end

When /^I quit uhwm$/ do
  uhwm_request_quit
  assert_exit_status 0
end

Then /^the exit status must be (\d+)$/ do |exit_status|
  assert_exit_status exit_status.to_i
end

Then /^uhwm must terminate successfully$/ do
  assert_exit_status 0
end
