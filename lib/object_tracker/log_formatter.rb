module ObjectTracker
  class LogFormatter < Logger::Formatter
    FORMAT = "[%s] %5s -- ObjectTracker: %s\n".freeze

    def call(severity, time, _progname, msg)
      FORMAT % [format_datetime(time), severity, msg2str(msg)]
    end
  end
end
