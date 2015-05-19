require 'benchmark'
require 'headless'
require 'uh/wm'
require 'uh/wm/testing/x_client'

n = 2 ** 16

Headless.ly do
  Benchmark.bm 12 do |x|
    io = nil
    cl = Uh::WM::Testing::XClient.new

    x.report 'start:' do
      io = IO.popen(%w[uhwm -v -f /dev/null])
      loop { break if io.gets.include? 'Working events' }
    end

    report = x.report 'maps/unmaps:' do
      n.times { cl.map.unmap }
      fail 'cannot quit uhwm' unless system 'xdotool key alt+shift+q'
      loop { break if io.gets.include? 'Quit requested' }
    end

    x.report 'stop:' do
      Process.wait(io.pid)
    end

    cl.destroy.terminate
    puts io.read if ENV.key 'VERBOSE'

    iter_time = report.real / n
    puts "\nIPS: %.2f (%.0f ns)" % [
      1 / iter_time,
      iter_time * 1000 * 1000,
    ]
  end
end
