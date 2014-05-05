class TestCase
  attr_reader :example
  attr_reader :result

  class AssertionError < StandardError; end
  class TestError < StandardError; end

  def initialize(example, result = TestResult.new)
    @example = example
    @result = result
  end

  def run
    result.test_started
    begin
      self.set_up
      self.public_send(example)
    rescue AssertionError => e
      puts e.inspect
      result.test_failed
    rescue => e
      puts e.inspect
      raise TestError unless calls_under_test?(e)
      result.test_failed
    end
    self.tear_down
    result
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
    result = TestResult.new
    example_classes.each do |example_class|
      run_example_class(example_class, result)
    end
    result
  end

  private

  def run_example_class(example_class, result)
    example_class.public_instance_methods(false).grep(/^test/).each do |example|
      example_class.new(example, result).run
    end
  end
end

class WasRun < TestCase
  attr_accessor :log

  def initialize(*)
    @log = []
    super
  end

  def set_up
    @log << 'set_up'
  end

  def testMethod
    @log << 'testMethod'
  end

  def testBrokenMethod
    sub_method
  end

  def sub_method
    raise "broken method"
  end

  def tear_down
    @log << 'tear_down'
  end
end

class WontRun < TestCase
  def set_up
    sub_method
  end

  def sub_method
    raise "won't run"
  end

  def testMethod
  end
end

class TestCaseTest < TestCase
  attr_reader :test

  def set_up
    @test = WasRun.new('testMethod')
  end

  def test_is_running
    test.run
    raise AssertionError unless test.log.include?('testMethod')
  end

  def test_is_set_up
    test.run
    raise AssertionError unless test.log.first == 'set_up'
  end

  def test_is_torn_down
    test.run
    raise AssertionError unless test.log.last == 'tear_down'
  end

  def test_reports_results
    result = test.run
    raise AssertionError unless result.summary == '1 run, 0 failed'
  end

  def test_formats_failed_results
    result = TestResult.new
    result.test_started
    result.test_failed
    raise AssertionError unless result.summary == '1 run, 1 failed'
  end

  def test_reports_failed_results
    @test = WasRun.new('testBrokenMethod')
    result = test.run
    raise AssertionError unless result.summary == '1 run, 1 failed'
  end

  def test_failed_setup_is_still_a_failure
    @test = WontRun.new('testMethod')
    result = test.run
    raise AssertionError unless result.summary == '1 run, 1 failed'
  end
end

class TestSuiteTest < TestCase
  def test_suite_runs_all_the_tests
    suite = TestSuite.new
    suite << WasRun
    result = suite.run
    raise AssertionError unless result.summary == '2 run, 1 failed'
  end
end

suite = TestSuite.new
suite << TestCaseTest << TestSuiteTest
puts suite.run.summary