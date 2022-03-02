Given /^another window manager is running$/ do
  expect(other_wm).to be_running
end

Given /^uhwm is running$/ do
  $_baf[:process] = uhwm_run_wait_ready
end

Given /^uhwm is running with options? (-.+)$/ do |options|
  $_baf[:process] = uhwm_run_wait_ready options
end

Given /^uhwm is running with this run control file:$/ do |rc|
  Baf::Testing.write_file '.uhwmrc.rb', rc
  $_baf[:process] = uhwm_run_wait_ready
end

When /^I quit uhwm$/ do
  uhwm_request_quit
  Baf::Testing.wait $_baf[:process]
  Baf::Testing.expect_ex $_baf[:process], 0
end
