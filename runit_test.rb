require 'runit'

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