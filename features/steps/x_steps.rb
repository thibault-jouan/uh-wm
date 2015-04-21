Given /^a (\w+) window is mapped$/ do |ident|
  x_window_map ident: ident
end

Given /^a window is managed$/ do
  x_window_map
  uhwm_wait_output /manag.+#{x_window_name}/i
end

When /^I press the ([^ ]+) keys?$/ do |keys|
  x_key keys
end

When /^a window requests to be mapped$/ do
  x_window_map
end

When /^the window requests to be unmapped$/ do
  x_window_unmap
end

When /^the (\w+) window requests to be unmapped$/ do |ident|
  x_window_unmap ident: ident
end

When /^a window requests to be mapped (\d+) times$/ do |times|
  x_window_map times: times.to_i
end

When /^the window is destroyed$/ do
  x_window_destroy
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(x_socket_check uhwm_pid).to be true
end

Then /^the window must be mapped$/ do
  expect(x_window_map_state).to eq 'IsViewable'
end

Then /^the (\w+) window must be mapped$/ do |ident|
  expect(x_window_map_state ident: ident).to eq 'IsViewable'
end

Then /^the window must be focused$/ do
  expect(x_focused_window_id).to eq x_window_id
end

Then /^the input event mask must include (.+)$/ do |mask|
  expect(x_input_event_masks).to include mask
end
