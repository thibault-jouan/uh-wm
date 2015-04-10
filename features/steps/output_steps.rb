def uhwm_wait_output message, timeout: 1
  Timeout.timeout(timeout) do
    loop do
      break if case message
        when Regexp then @process.read_stdout =~ message
        when String then assert_partial_output_interactive message
      end
      sleep 0.1
    end
  end
rescue Timeout::Error
  fail [
    "expected `#{message}' not seen after #{timeout} seconds in:",
    "```\n#{@process.stdout + @process.stderr}```"
  ].join "\n"
end

Then /^the output must contain exactly the usage$/ do
  assert_exact_output <<-eoh, all_output
Usage: uhwm [options]

options:
    -h, --help                       print this message
    -v, --version                    enable verbose mode
    -d, --debug                      enable debug mode
  eoh
end

Then /^the current output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  uhwm_wait_output Regexp.new(pattern, options)
end
