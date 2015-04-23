Then /^the output must contain exactly the usage$/ do
  assert_exact_output <<-eoh, all_output
Usage: uhwm [options]

options:
    -v, --verbose                    enable verbose mode
    -d, --debug                      enable debug mode
    -f, --run-control PATH           specify alternate run control file
    -r, --require PATH               require ruby feature
    -l, --layout LAYOUT              specify layout
    -w, --worker WORKER              specify worker

    -h, --help                       print this message
    -V, --version                    print version
  eoh
end

Then /^the output must contain exactly the version$/ do
  assert_exact_output "%s\n" % Uh::WM::VERSION, all_output
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  uhwm_wait_output Regexp.new(pattern, options)
end

Then /^the output must not match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  expect(all_output).not_to match Regexp.new(pattern, options)
end

Then /^the output must match \/([^\/]+)\/([a-z]*) at least (\d+) times$/ do
    |pattern, options, times|
  uhwm_wait_output Regexp.new(pattern, options), times.to_i
end

Then /^the output must match \/([^\/]+)\/([a-z]*) exactly (\d+) times$/ do
    |pattern, options, times|
  scans = uhwm_wait_output Regexp.new(pattern, options)
  expect(scans.size).to eq times.to_i
end

Then /^the output must contain:$/ do |content|
  uhwm_wait_output content.to_s
end

Then /^the output must contain "([^"]+)"$/ do |content|
  uhwm_wait_output content.to_s
end

Then /^the output must contain current display$/ do
  uhwm_wait_output ENV['DISPLAY']
end

Then /^the output must contain the window name$/ do
  uhwm_wait_output x_window_name
end
