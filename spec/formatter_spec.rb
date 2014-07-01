require_relative 'spec_helper'
require 'strftime_logger'
require 'fileutils'

describe StrftimeLogger do
  subject { StrftimeLogger.new("#{log_dir}/application.log.%Y%m%d") }
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
    begin
      raise ArgumentError.new('test')
    rescue => e
      subject.write(e)
    end
    File.open("#{log_dir}/application.log.#{today}") do |f|
      expect(f.gets).to eq "#{now} [INFO] test\n"
      expect(f.gets).to match(/#{Regexp.escape(now)} \[INFO\] ArgumentError test/)
    end
  end
end
