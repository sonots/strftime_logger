require_relative 'spec_helper'
require 'strftime_logger'
require 'fileutils'

describe StrftimeLogger do
  let(:log_dir)   { "#{File.dirname(__FILE__)}/log" }

  before do
    Dir.mkdir(log_dir)
    Timecop.freeze(Time.now)
  end

  after do
    FileUtils.rm_rf log_dir
    Timecop.return
  end

  context :write do
    subject { StrftimeLogger.new("#{log_dir}/application.log.%Y%m%d") }
    let(:today)     { Time.now.strftime "%Y%m%d"}
    let(:now)       { Time.now.iso8601 }

    it :write do
      subject.write("test")
      subject.write("test")
      expect(File.read("#{log_dir}/application.log.#{today}")).to eq "test\n"*2
    end

    LEVEL_TEXT = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)
    %w[debug info warn error fatal unknown].each_with_index do |level, severity|
      it level do
        subject.__send__(level, "test")
        expect(File.read("#{log_dir}/application.log.#{today}")).to eq "#{now} [#{LEVEL_TEXT[severity]}] test\n"
      end
    end

    it 'multiline' do
      subject.info("foo\nbar")
      expect(File.read("#{log_dir}/application.log.#{today}")).to eq "#{now} [INFO] foo\\nbar\n"
    end

    it 'rotate log' do
      subject.info("test")
      Timecop.freeze(Time.now + 24 * 60 * 60)
      subject.info("test")
      yesterday = (Time.now - 24 * 60 * 60).strftime "%Y%m%d"
      one_day_ago = (Time.now - 24 * 60 * 60).iso8601
      expect(File.read("#{log_dir}/application.log.#{yesterday}")).to eq "#{one_day_ago} [INFO] test\n"
      expect(File.read("#{log_dir}/application.log.#{today}")).to eq "#{now} [INFO] test\n"
    end
  end

  context :new do
    let(:now) { Time.now.iso8601 }

    it 'date format' do
      logger = StrftimeLogger.new("#{log_dir}/application.log.%Y%m%d_%H")
      current_hour = Time.now.strftime "%Y%m%d_%H"
      logger.info("test")
      expect(File.read("#{log_dir}/application.log.#{current_hour}")).to eq "#{now} [INFO] test\n"
    end

    it 'file per level' do
      logger = StrftimeLogger.new({
        debug:   "#{log_dir}/application.debug.log",
        info:    "#{log_dir}/application.info.log",
        warn:    "#{log_dir}/application.warn.log",
        error:   "#{log_dir}/application.error.log",
        fatal:   "#{log_dir}/application.fatal.log",
        unknown: "#{log_dir}/application.unknown.log"
      })
      logger.info("test")
      expect(File.read("#{log_dir}/application.info.log")).to eq "#{now} [INFO] test\n"
    end

    it 'level=' do
      logger = StrftimeLogger.new("#{log_dir}/application.log")
      logger.level = StrftimeLogger::WARN
      logger.info("test")
      logger.warn("test")
      expect(File.read("#{log_dir}/application.log")).to eq "#{now} [WARN] test\n"
    end

    class MockAdapter
      def initialize(level, path)
      end
      def write(msg)
        ::File.open("#{File.dirname(__FILE__)}/log/mock", 'a+') do |f|
          f.write msg
          f.flush
        end
      end
    end

    describe 'switch adapter' do
      it 'class and instance' do
        logger = StrftimeLogger.new("#{log_dir}/test", {debug: [MockAdapter, MockAdapter.new('mock', 'mock')]})
        logger.debug('mock')
        expect(File.read("#{log_dir}/mock")).to eq "#{now} [DEBUG] mock\n#{now} [DEBUG] mock\n"
      end
    end
  end
end

