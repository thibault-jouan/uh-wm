Then /^it must connect to X display$/ do
  Timeout.timeout(exit_timeout) do
    loop do
      break if assert_partial_output_interactive 'Connected to'
      sleep 0.1
    end
  end
  expect(`sockstat -u`.lines.grep /\s+ruby.+\s+#{@process.pid}/)
    .not_to be_empty
end
