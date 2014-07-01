$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'strftime_logger'
require 'parallel'

logger = StrftimeLogger.new("#{__dir__}/test.log")
Parallel.map(['a', 'b'], :in_threads => 2) do |letter|
  3000.times do
    logger.info letter * 5000
  end
end

# egrep -e 'ab' -e 'ba' test.log
# これはまざらない
