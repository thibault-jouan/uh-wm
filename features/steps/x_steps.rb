When /^I press the ([^ ]+) keys?$/ do |keys|
  x_key keys
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(x_socket_check uhwm_pid).to be true
end
