require_relative 'spec_helper'
require 'strftime_logger'
require 'fileutils'

describe StrftimeLogger do
  subject do
    StrftimeLogger.new("#{log_dir}/application.log.%Y%m%d").tap {|logger|
      logger.formatter = StrftimeLogger::LtsvFormatter.new
    }
  end
  let(:log_dir)   { "#{File.dirname(__FILE__)}/log" }
  let(:today)     { Time.now.strftime "%Y%m%d"}
  let(:now)       { Time.now.iso8601 }

  before do
    Dir.mkdir(log_dir)
    Timecop.freeze(Time.now)
  end

  after do
    FileUtils.rm_rf log_dir
    Timecop.return
  end

  it :write do
    subject.write("test")
    subject.write({a:1, b:2})
    File.open("#{log_dir}/application.log.#{today}") do |f|
      expect(f.gets).to eq "time:#{now}\tmessage:test\n"
      expect(f.gets).to eq "time:#{now}\ta:1\tb:2\n"
    end
  end
end
