Given /^a (\w+) window is mapped$/ do |ident|
  x_client(ident).map.sync
end

Given /^a window is managed$/ do
  x_client.map.sync
  uhwm_wait_output /manag.+#{x_client.name}/i
end

When /^I press the ([^ ]+) keys?$/ do |keys|
  x_key keys
end

When /^a window requests to be mapped$/ do
  x_client.map.sync
end

When /^a window requests to be mapped (\d+) times$/ do |times|
  x_client.map times: times.to_i
end

When /^the window requests to be unmapped$/ do
  x_client.unmap.sync
end

When /^the (\w+) window is unmapped$/ do |ident|
  x_client(ident).unmap.sync
  uhwm_wait_output /unmanag.+#{x_client(ident).name}/i
end

When /^the window is destroyed$/ do
  x_client.destroy.sync
end

Then /^it must connect to X display$/ do
  uhwm_wait_ready
  expect(x_socket_check uhwm.pid).to be true
end

Then /^the window must be mapped$/ do
  expect(x_window_map_state x_client.window_id).to eq 'IsViewable'
end

Then /^the (\w+) window must be mapped$/ do |ident|
  expect(x_window_map_state x_client(ident).window_id).to eq 'IsViewable'
end

Then /^the window must be focused$/ do
  expect(x_focused_window_id).to eq x_client.window_id
end

Then /^the input event mask must include (.+)$/ do |mask|
  expect(x_input_event_masks).to include mask
end
