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
  expect(all_output).to match /\A\d+\.\d+\.\d+\n\z/
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  uhwm_wait_output build_regexp(pattern, options)
end

Then /^the output must match \/([^\/]+)\/([a-z]*) exactly (\d+) times$/ do
    |pattern, options, times|
  scans = uhwm_wait_output build_regexp(pattern, options)
  expect(scans.size).to eq times.to_i
end

Then /^the output must contain "([^"]+)"$/ do |content|
  uhwm_wait_output content.to_s
end

Then /^the output must contain current display$/ do
  uhwm_wait_output ENV['DISPLAY']
end
