module Uh
  module WM
    class LoggerFormatter
      FORMAT_STR = "%s.%03i %s: %s\n".freeze

      def call severity, datetime, _progname, message
        FORMAT_STR % [
          datetime.strftime('%FT%T'),
          datetime.usec / 1000,
          severity[0..0],
          message
        ]
      end
    end
  end
end
