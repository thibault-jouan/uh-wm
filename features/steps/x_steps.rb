When /^I press the default quit key binding$/ do
  x_key 'alt+q'
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(x_socket_check uhwm_pid).to be true
end
