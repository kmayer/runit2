class TestError < StandardError; end

module Assertions
  class AssertionError < StandardError; end

  def assert(assertion, explanation = nil)
    return if assertion
    message = "#{example}: #{explanation} [FAIL]"
    $stderr.puts message
    raise AssertionError, message
  end

  def assert_equal(result, expected, explanation = nil)
    message = ["#{result.inspect} should have equaled #{expected.inspect}", explanation].join(': ')
    assert(result == expected, message)
  end
end

class TestCase
  include Assertions
  attr_reader :example
  attr_reader :result

  def initialize(example, result = TestResult.new)
    @example = example
    @result = result
  end

  def run
    result.tap do |result|
      result.test_started
      begin
        self.set_up
        self.public_send(example)
      rescue AssertionError => e
        result.test_failed
      rescue => e
        puts e.inspect
        raise TestError unless calls_under_test?(e)
        result.test_failed
      end
      self.tear_down
    end
  end

  def set_up
  end

  def tear_down
  end

  private

  def calls_under_test?(e)
    stack_trace = e.backtrace_locations.map(&:base_label).take_while{|m| m != 'run'}

    stack_trace[-2] == example.to_s || stack_trace[-1] == 'set_up'
  end
end

class TestResult
  attr_accessor :run_count
  attr_accessor :failed_count

  def initialize
    @run_count = 0
    @failed_count = 0
  end

  def test_started
    @run_count += 1
  end

  def test_failed
    @failed_count += 1
  end

  def summary
    '%d run, %d failed' % [run_count, failed_count]
  end
end

class TestSuite
  attr_reader :example_classes

  def initialize
    @example_classes = []
  end

  def <<(example_class)
    @example_classes << example_class; self
  end

  def run
    TestResult.new.tap do |result|
      example_classes.each do |example_class|
        run_example_class(example_class, result)
      end
    end
  end

  private

  def run_example_class(example_class, result)
    example_class.public_instance_methods(false).grep(/^test/).each do |example|
      example_class.new(example, result).run
    end
  end
end
