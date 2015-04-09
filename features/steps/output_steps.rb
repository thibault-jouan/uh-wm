def uhwm_wait_output message, timeout: 1
  Timeout.timeout(timeout) do
    loop do
      break if case message
      when Regexp
        @process.read_stdout =~ message
      when String
        assert_partial_output_interactive message
      end
      sleep 0.1
    end
  end
rescue Timeout::Error
  fail "expected message `#{message}' not seen after #{timeout} seconds"
end

Then /^the output must contain exactly the usage$/ do
  assert_exact_output <<-eoh, all_output
Usage: uhwm [options]

options:
    -h, --help                       print this message
    -v, --version                    enable verbose mode
  eoh
end

Then /^the current output must match \/([^\/]+)\/([a-z]+)$/ do |pattern, options|
  uhwm_wait_output Regexp.new(pattern, options)
end
