def uhwm_wait_output message, timeout: 1
  Timeout.timeout(timeout) do
    loop do
      break if assert_partial_output_interactive message
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
  eoh
end
