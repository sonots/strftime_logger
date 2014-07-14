class StrftimeLogger
  require 'strftime_logger/formatter'
  require 'strftime_logger/ltsv_formatter'
  require 'strftime_logger/bridge'
  require 'strftime_logger/adapter/file'

  SEV_LABEL = [:debug, :info, :warn, :error, :fatal, :unknown]

  # Logging severity.
  module Severity
    # Low-level information, mostly for developers
    DEBUG = 0
    # generic, useful information about system operation
    INFO = 1
    # a warning
    WARN = 2
    # a handleable error condition
    ERROR = 3
    # an unhandleable error that results in a program crash
    FATAL = 4
    # an unknown message that should always be logged
    UNKNOWN = 5
  end
  include Severity

  # Logging severity threshold (e.g. <tt>Logger::INFO</tt>).
  attr_accessor :level
  attr_accessor :formatter

  # @param [Hash|IO|String] path 
  # @param [Hash] adapters
  #
  # Example:
  # 
  #     StrftimeLogger.new('/var/log/foo/webapp.log.%Y%m%d') # String
  #     StrftimeLogger.new('/var/log/foo/webapp.log.%Y%m%d_%H')
  #
  # Exampl2:
  #
  #     # Hash
  #     StrftimeLogger.new({
  #       debug:   '/var/log/foo/webapp.debug.log.%Y%m%d',
  #       info:    '/var/log/foo/webapp.info.log.%Y%m%d',
  #       warn:    '/var/log/foo/webapp.warn.log.%Y%m%d',
  #       error:   '/var/log/foo/webapp.error.log.%Y%m%d',
  #       fatal:   '/var/log/foo/webapp.fatal.log.%Y%m%d',
  #       unknown: '/var/log/foo/webapp.unknown.log.%Y%m%d'
  #     })
  #
  # Exampl3:
  #
  #     # With Specified Adapter
  #     StrftimeLogger.new('/var/log/foo/webapp.log.%Y%m%d', [StrftimeLogger::Adapter::File])
  def initialize(path, adapter = nil)
    @level = DEBUG
    @default_formatter = StrftimeLogger::Formatter.new
    @formatter = nil

    if path.is_a?(Hash)
      @path = path
    else
      # make a hash
      keys = SEV_LABEL
      vals = [path] * keys.size
      @path = Hash[*(keys.zip(vals).flatten(1))]
    end

    if adapter.nil?
      @adapter = {}
    elsif adapter.is_a?(Hash)
      @adapter = adapter
    else
      # make a hash
      keys = SEV_LABEL
      vals = [adapter] * keys.size
      @adapter = Hash[*(keys.zip(vals).flatten(1))]
    end

    @bridge = {}
    SEV_LABEL.each do |level|
      @bridge[level] = StrftimeLogger::Bridge.new(level, @path[level], @adapter[level])
    end
  end

  def self.str_to_level(str)
    SEV_LABEL.index(str.to_s.downcase.to_sym)
  end 

  def log_level=(log_level)
    @level = self.class.str_to_level(log_level)
  end 

  # @param severity [Int] log severity
  def add(severity, message = nil, &block)
    severity ||= UNKNOWN

    if @bridge.nil? or severity < @level
      return true
    end

    log_level = SEV_LABEL[severity]
    if @bridge[log_level].nil?
      @bridge[log_level] = StrftimeLogger::Adapter.new(log_level, @path[log_level])
    end

    @bridge[log_level].write(format_message(severity, message, &block))
    true
  end
  alias log add

  def debug(msg, &block)
    add(DEBUG, msg, &block)
  end

  def info(msg, &block)
    add(INFO, msg, &block)
  end

  def warn(msg, &block)
    add(WARN, msg, &block)
  end

  def error(msg, &block)
    add(ERROR, msg, &block)
  end

  def fatal(msg,  &block)
    add(FATAL, msg, &block)
  end

  def unknown(msg, &block)
    add(UNKNOWN, msg, &block)
  end

  def write(msg)
    msg.chomp! if msg.respond_to?(:chomp!)
    @bridge[:info].write(format_message(nil, msg))
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +DEBUG+ messages.
  def debug?; @level <= DEBUG; end

  # Returns +true+ iff the current severity level allows for the printing of
  # +INFO+ messages.
  def info?; @level <= INFO; end

  # Returns +true+ iff the current severity level allows for the printing of
  # +WARN+ messages.
  def warn?; @level <= WARN; end

  # Returns +true+ iff the current severity level allows for the printing of
  # +ERROR+ messages.
  def error?; @level <= ERROR; end

  # Returns +true+ iff the current severity level allows for the printing of
  # +FATAL+ messages.
  def fatal?; @level <= FATAL; end

  def close
    SEV_LABEL.each do |level|
      next if @bridge[level].nil?
      @bridge[level].close
    end
  end

  def format_message(severity, message = nil, &block)
    (@formatter || @default_formatter).call(severity, message, &block)
  end
end


