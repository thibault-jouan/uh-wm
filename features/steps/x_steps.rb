def x_key key
  fail "cannot simulate X key `#{key}'" unless system "xdotool key #{key}"
end

def x_socket_check pid
  case RbConfig::CONFIG['host_os']
  when /linux/
    `netstat -xp 2> /dev/null`.lines.grep /\s+#{pid}\/ruby/
  else
    `sockstat -u`.lines.grep /\s+ruby.+\s+#{pid}/
  end.any?
end

When /^I press the default quit key binding$/ do
  x_key 'alt+q'
end

Then /^it must connect to X display$/ do
  uhwm_wait_output 'Connected to'
  expect(x_socket_check @process.pid).to be true
end
