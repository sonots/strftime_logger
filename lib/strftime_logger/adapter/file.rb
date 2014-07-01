require 'monitor'

class StrftimeLogger
  class Adapter
    class File

      class LogFileMutex
        include MonitorMixin
      end

      def initialize(level, path)
        @level = level
        @path = path
        @timestamp_path = Time.now.strftime(path)
        @mutex = LogFileMutex.new
        @log = open_logfile(@timestamp_path)
      end

      def write(msg)
        begin
          @mutex.synchronize do
            if @log.nil? || !same_path?
              begin
                @timestamp_path = Time.now.strftime(@path)
                @log.close rescue nil
                @log = create_logfile(@timestamp_path)
              rescue
                warn("log shifting failed. #{$!}")
              end
            end

            begin
              @log.write msg
            rescue
              warn("log writing failed. #{$!}")
            end
          end
        rescue Exception => ignored
          warn("log writing failed. #{ignored}")
        end
      end

      def close
        if !@log.nil? && !@log.closed?
          @log.close
        end
      end

      private

      # return nil if file not found
      def open_logfile(filename)
        begin
          f = ::File.open filename, (::File::WRONLY | ::File::APPEND)
          f.sync = true
        rescue Errno::ENOENT
          return nil
        end
        f
      end

      def create_logfile(filename)
        begin
          f = ::File.open filename, (::File::WRONLY | ::File::APPEND | ::File::CREAT | ::File::EXCL)
          f.sync = true
        rescue Errno::EEXIST
          f = open_logfile(filename)
        end
        f
      end

      def same_path?
        @timestamp_path == Time.now.strftime(@path)
      end
    end
  end
end
