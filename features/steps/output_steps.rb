Then /^the output must contain exactly the usage$/ do
  expect_output <<-eoh
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
  expect(last_command_started.output).to match /\A\d+\.\d+\.\d+\n\z/
end

Then /^the output must match \/([^\/]+)\/([a-z]*) exactly (\d+) times$/ do
    |pattern, options, times|
  scans = wait_output! build_regexp(pattern, options)
  expect(scans.size).to eq times.to_i
end

Then /^the output will contain current display$/ do
  wait_output! ENV['DISPLAY']
end
