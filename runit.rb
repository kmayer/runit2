class TestError < StandardError; end

module Assertions
  class AssertionError < StandardError; end

  def assert(assertion, explanation = nil)
    return if assertion
    message = "[FAIL] #{example}: #{explanation}"
    logger.puts message.squeeze(' ')
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
  attr_reader :logger

  def initialize(example, result = TestResult.new, logger = StringIO.new)
    @example = example
    @result = result
    @logger = logger
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
        logger.puts "#{example}: #{e.inspect}"
        raise TestError unless calls_under_test?(e)
        result.test_errored
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
  attr_accessor :error_count

  def initialize
    @run_count = 0
    @failed_count = 0
    @error_count = 0
  end

  def test_started
    @run_count += 1
  end

  def test_failed
    @failed_count += 1
  end

  def test_errored
    @error_count += 1
  end

  def succeeded?
    @run_count > 0 && @failed_count == 0 && @error_count == 0
  end

  def summary
    if error_count > 0
      '%d run, %d failed, %d error' % [run_count, failed_count, error_count]
    else
      '%d run, %d failed' % [run_count, failed_count]
    end
  end
end

class TestSuite
  attr_reader :example_classes
  attr_reader :result
  attr_reader :logger

  def initialize
    @example_classes = []
    @logger = StringIO.new
    @result = TestResult.new
  end

  def <<(example_class)
    @example_classes << example_class; self
  end

  def run
    example_classes.each do |example_class|
      run_example_class(example_class)
    end
    result
  end

  private

  def run_example_class(example_class)
    example_class.public_instance_methods(false).grep(/^test.+/).each do |example|
      example_class.new(example, result, logger).run
    end
  end
end
