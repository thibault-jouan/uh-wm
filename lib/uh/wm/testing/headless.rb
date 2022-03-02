require 'baf/testing/process'

module Uh
  module WM
    module Testing
      module Headless
        DISPLAY_NAME    = ':42'
        DISPLAY_SCREEN  = '640x480x24'

        def with_xvfb
          xvfb = Baf::Testing::Process.new %W[
            Xvfb -ac #{DISPLAY_NAME} -screen 0 #{DISPLAY_SCREEN}
          ]
          xvfb.start
          original_display = ENV['DISPLAY']
          ENV['DISPLAY'] = DISPLAY_NAME
          begin
            yield
          ensure
            ENV['DISPLAY'] = original_display
            xvfb.stop
          end
        end
      end
    end
  end
end
