require 'benchmark'

require 'uh/wm'
require 'uh/wm/testing/headless'
require 'uh/wm/testing/x_client'

include Uh::WM::Testing::Headless

def wait_output io, message
  loop { break if io.gets.include? message }
end

with_xvfb do
  Benchmark.bm 12 do |x|
    n   = 2 ** 16
    io  = nil
    cl  = Uh::WM::Testing::XClient.new

    x.report 'start:' do
      io = IO.popen(%w[./bin/uhwm -v -f /dev/null])
      wait_output io, 'Working events'
    end

    report = x.report 'maps/unmaps:' do
      n.times { cl.map.unmap }
      fail 'cannot quit uhwm' unless system 'xdotool key alt+shift+q'
      wait_output io, 'Quit requested'
    end

    x.report 'stop:' do
      Process.wait(io.pid)
    end

    cl.destroy.terminate

    iter_time = report.real / n
    puts "\nIPS: %.2f (%.0f ns)" % [
      1 / iter_time,
      iter_time * 1000 * 1000,
    ]
  end
end
