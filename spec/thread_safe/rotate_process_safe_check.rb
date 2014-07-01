$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'strftime_logger'
require 'parallel'
require 'timecop'
require 'test/unit'

Timecop.scale(24 * 60 * 60)

$proc_num = 2
$execute_num = 10000

logger = StrftimeLogger.new("#{__dir__}/test.log.%Y%m%d")
Parallel.map(['a', 'b'], :in_processes => $proc_num) do |letter|
  $execute_num.times do
  logger.info letter * 5000
  end
end

$total_num = `LANG=C wc -l #{__dir__}/test.log.*`.split("\n").map(&:strip).grep(/\stotal\z/).first.split(' ').first.to_i
p "Actually total line num #{$total_num}"
p "Expected total line num #{$execute_num * $proc_num}"

class StrftimeLoggerTC < Test::Unit::TestCase
  def test_logger
    assert_equal($execute_num * $proc_num, $total_num)
  end
  def teardown
    p 'rm -rf #{__dir__}/test.log.*'
  end
end

=begin
% ruby example/rotate_process_safe_check.rb
no warn!!!
=end

