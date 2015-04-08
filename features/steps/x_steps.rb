Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(`sockstat -u`.lines.grep /\s+ruby.+\s+#{@process.pid}/)
    .not_to be_empty
end
