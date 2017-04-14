module ObjectTracker
  class LogFormatter < Logger::Formatter
    FORMAT = "[%s] %5s -- ObjectTracker: %s\n".freeze
    TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%6N".freeze

    def call(severity, time, _progname, msg)
      FORMAT % [time.strftime(TIME_FORMAT), severity, msg2str(msg)]
    end
  end
end
