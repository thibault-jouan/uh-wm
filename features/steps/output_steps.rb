Then /^the output must contain exactly the usage$/ do
  expect($_baf[:process].output).to eq <<-eoh
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
  expect($_baf[:process].output).to match /\A\d+\.\d+\.\d+\n\z/
end

Then /^the output must match \/([^\/]+)\/([a-z]*) exactly (\d+) times$/ do
    |pattern, options, times|
  scans = wait_output Baf::Testing.build_regexp pattern, options
  expect(scans.size).to eq times.to_i
end

Then /^the output will contain current display$/ do
  wait_output ENV['DISPLAY']
end
