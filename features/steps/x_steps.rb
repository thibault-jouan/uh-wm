When /^I press the ([^ ]+) keys?$/ do |keys|
  x_key keys
end

When /^a window requests to be mapped$/ do
  x_window_map
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(x_socket_check uhwm_pid).to be true
end

Then /^the window must be mapped$/ do
  expect(x_window_map_state).to eq 'IsViewable'
end

Then /^the window must be focused$/ do
  expect(x_focused_window_id).to eq x_window_id
end

Then /^the input event mask must include (.+)$/ do |mask|
  expect(x_input_event_masks).to include mask
end
