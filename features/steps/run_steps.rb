def uhwm_run options = '-v'
  command = %w[uhwm]
  command << options if options
  @interactive = @process = run command.join ' '
end

def uhwm_run_wait_ready
  uhwm_run
  uhwm_wait_output 'Connected to'
end

Given /^another window manager is running$/ do
  expect(@other_wm).to be_alive
end

Given /^uhwm is running$/ do
  uhwm_run_wait_ready
end

When /^I start uhwm$/ do
  uhwm_run
end

When /^I run uhwm with options? (-.+)$/ do |options|
  uhwm_run options
end

Then /^the exit status must be (\d+)$/ do |exit_status|
  assert_exit_status exit_status.to_i
end

Then /^uhwm should terminate successfully$/ do
  assert_exit_status 0
end
