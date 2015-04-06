When /^I start uhwm$/ do
  @process = run 'uhwm'
  @interactive = @process
end
