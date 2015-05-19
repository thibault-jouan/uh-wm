require 'benchmark'
require 'headless'
require 'uh/wm'
require 'uh/wm/testing/x_client'

include Uh::WM::Testing::AcceptanceHelpers

n = 100

Headless.ly do
  io = IO.popen(%w[uhwm -v -f /dev/null])
  loop do
    break if io.gets.include? 'Working events'
  end

  cl = XClient.new
  Benchmark.benchmark do |bm|
    bm.report do
      n.times do
        cl.map.unmap
      end
    end
  end
  cl.destroy.terminate

  fail 'cannot quit uhwm' unless system 'xdotool key alt+shift+q'
  Process.wait(io.pid)
  puts io.read
end
