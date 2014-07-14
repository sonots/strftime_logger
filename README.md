# StrftimeLogger

A logger treats log rotation in strftime fashion.

## What is this for?

The ruby's built-in logger does log rotation in the basis of log size.
In contrast, `StrftimeLogger` provides a feature to rotate logs in the basis of time.

This logger allows to specify the log path with `strftime` format such as:

```
logger = StrftimeLogger.new('/var/log/application.log.%Y%m%d')
```

which enables to rotate logs in each specific time.

In fact, this logger does not rotate logs, but outputs to the strftime formatted path directly. 

This characteristic gives a side effect that it does not require to lock files in log rotation. 

## Installation

Add this line to your application's Gemfile:

    gem 'strftime_logger'

And then execute:

    $ bundle

## How to use

### Normal Usage

```ruby
require 'strftime_logger'
logger = StrftimeLogger.new('/var/log/application.log.%Y%m%d')
logger.info("foo\nbar")
```

which outputs logs to `/var/log/application.log.YYYYMMDD` with contents like

```
20140630T00:00:00+09:00 [INFO] foo\\nbar
```

where the time is in ISO8601 format, and the line feed characters `\n` in log messages
are replaced with `\\n` so that the log message will be in one line.

### Change the log level

```
logger.level = StrftimeLogger::WARN
```

Or, short-hand: 

```
logger.log_level = 'WARN'
```

### Change the Formatter

It is possible to change the logger formmater as:

```ruby
logger.formatter = SampleFormatter.new
```

The interface which the costom formmatter must provide is only `#initialize(opts = {})` and `#call(sevirity, message = nil, &block)`. Following is a simple example:

```ruby
class SampleFormatter
  LEVEL_TEXT = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN)

  def initialize(opts={})
  end

  # @param sevirity [int] log sevirity
  def call(severity, message = nil, &block)
    if message.nil?
      if block_given?
        message = yield
      else
        message = ""
      end
    end
    "#{Time.now} #{LEVEL_TEXT[sevirity]} #{message}"
  end
end
```

## ToDo

* Support datetime_format

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

See [LICENSE.txt](LICENSE.txt) for details.
