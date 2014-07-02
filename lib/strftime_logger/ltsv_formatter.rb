require 'time'

class StrftimeLogger
  class LtsvFormatter
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
      time = Time.now.iso8601
      "time:#{time}\t#{format_message(message)}\n"
    end

    private

    def format_message(message)
      unless message.is_a?(Hash)
        message = { message: message }
      end
      message.map {|k, v| "#{k}:#{v}" }.join("\t")
    end
  end
end
