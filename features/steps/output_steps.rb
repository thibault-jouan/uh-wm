Then /^the output must contain exactly the usage$/ do
  assert_exact_output <<-eoh, all_output
Usage: uhwm [options]

options:
    -h, --help                       print this message
    -v, --verbose                    enable verbose mode
    -d, --debug                      enable debug mode
    -f, --run-control PATH           specify alternate run control file
    -r, --require PATH               require ruby feature
    -l, --layout LAYOUT              specify layout
    -w, --worker WORKER              specify worker
    -V, --version                    print version
  eoh
end

Then /^the output must contain exactly the version$/ do
  #require File.expand_path('../lib/uh/wm/version', __FILE__)
  assert_exact_output "%s\n" % Uh::WM::VERSION, all_output
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  uhwm_wait_output Regexp.new(pattern, options)
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
