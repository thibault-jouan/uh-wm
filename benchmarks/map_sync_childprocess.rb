require 'benchmark'
require 'childprocess'
require 'timeout'

require 'uh/wm'
require 'uh/wm/testing/acceptance_helpers'
require 'uh/wm/testing/headless'

include Uh::WM::Testing::Headless
include Uh::WM::Testing::AcceptanceHelpers

n = 100_000

with_xvfb do
  r, w = IO.pipe
  uhwm = ChildProcess.build(*%w[uhwm -v -f /dev/null])
  uhwm.io.stdout = uhwm.io.stderr = w
  uhwm.start
  Timeout.timeout(2) do
    loop do
      begin
        break if r.read_nonblock(256).include? 'Working events'
      rescue IO::EAGAINWaitReadable
        sleep 0.1
        retry
      end
    end
  end
  puts 'OK!'

  Benchmark.benchmark do |bm|
    bm.report do
      n.times { x_client.map.sync.unmap.sync }
    end
  end

  fail 'cannot quit uhwm' unless system 'xdotool key alt+shift+q'
  uhwm.stop
end
