require_relative 'adapter/file'

class StrftimeLogger
  # A birdge to support logger's adapters. 
  # This interface enables for the logger to output not only into file, but aslo syslog, fluentd, and queue, etc.
  #
  # In addition, one or some adapters can be configured for **each** log level. 
  # If multiple adapters are specified, writing a log will output to the multiple destinations.
  class Bridge

    # @param [Symbol] level
    def initialize(level, name, adapters = nil)
      set_adapters(level, name, adapters)
    end

    def write(msg)
      @adapters.each do |adapter|
        adapter.write(msg)
      end
    end

    def close
      @adapters.each do |adapter|
        adapter.close
      end
    end

    private
    def default_adapters
      {
        debug:   [StrftimeLogger::Adapter::File],
        info:    [StrftimeLogger::Adapter::File],
        warn:    [StrftimeLogger::Adapter::File],
        error:   [StrftimeLogger::Adapter::File],
        fatal:   [StrftimeLogger::Adapter::File],
        unknown: [StrftimeLogger::Adapter::File],
      }
    end

    def set_adapters(level, name, adapters = nil)
      @adapters = Array.new
      (adapters || default_adapters[level]).each do |adapter|
        case adapter
        when Class
          @adapters.push adapter.new(level, name)
        else
          @adapters.push adapter
        end
      end
    end
  end
end


