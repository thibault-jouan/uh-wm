def uhwm_run options = nil
  command = %w[uhwm]
  command << options if options
  @interactive = @process = run command.join ' '
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
