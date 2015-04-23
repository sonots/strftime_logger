require 'time'

class StrftimeLogger
  class Formatter
    FORMAT = "%s [%s] %s\n"
    LEVEL_TEXT = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)

    def initialize(opts={})
    end

    def call(severity, message = nil, &block)
      if message.nil?
        if block_given?
          message = yield
        else
          message = ""
        end
      end
      if severity.nil?
        format_message(message) + "\n"
      else
        FORMAT % [format_datetime(Time.now), format_severity(severity), format_message(message)]
      end
    end

    private
    def format_datetime(time)
      time.iso8601
    end

    def format_severity(severity)
      LEVEL_TEXT[severity]
    end

    def format_message(message)
      case message
      when ::Exception
        e = message
        "#{e.class} (#{e.message})\\n  #{e.backtrace.join("\\n  ")}"
      else
        message.to_s.gsub(/\n/, "\\n")
      end
    end
  end
end
