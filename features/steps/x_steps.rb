def x_key key
  fail "cannot simulate X key `#{key}'" unless system "xdotool key #{key}"
end

When /^I press the default quit key binding$/ do
  x_key 'alt+q'
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(`sockstat -u`.lines.grep /\s+ruby.+\s+#{@process.pid}/)
    .not_to be_empty
end
