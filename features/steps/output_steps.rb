def uhwm_wait_output message, timeout: 1
  Timeout.timeout(timeout) do
    loop do
      break if case message
        when Regexp then @process.stdout + @process.stderr =~ message
        when String then assert_partial_output_interactive message
      end
      sleep 0.1
    end
  end
rescue Timeout::Error
  fail [
    "expected `#{message}' not seen after #{timeout} seconds in:",
    "  ```\n  #{@process.stdout + @process.stderr}  ```"
  ].join "\n"
end

Then /^the output must contain exactly the usage$/ do
  assert_exact_output <<-eoh, all_output
Usage: uhwm [options]

options:
    -h, --help                       print this message
    -v, --version                    enable verbose mode
    -d, --debug                      enable debug mode
    -r, --require PATH               require ruby feature
    -l, --layout LAYOUT              specify layout
  eoh
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  expect(@process.stdout).to match Regexp.new(pattern, options)
end

Then /^the current output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  uhwm_wait_output Regexp.new(pattern, options)
end

Then /^the current output must contain:$/ do |content|
  uhwm_wait_output content.to_s
end

Then /^the current output must contain current display$/ do
  uhwm_wait_output ENV['DISPLAY']
end
