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

  def testFailedMethod
    assert(false)
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
    assert test.log.include?('testMethod')
  end

  def test_is_set_up
    test.run
    assert_equal test.log.first, 'set_up'
  end

  def test_is_torn_down
    test.run
    assert_equal test.log.last, 'tear_down'
  end

  def test_reports_results
    result = test.run
    assert_equal result.summary, '1 run, 0 failed'
  end

  def test_reports_failed_results
    @test = WasRun.new('testFailedMethod')
    result = test.run
    assert_equal result.summary, '1 run, 1 failed'
  end

  def test_failed_setup_is_still_a_failure
    @test = WontRun.new('testMethod')
    result = test.run
    assert_equal result.summary, '1 run, 0 failed, 1 error'
  end
end

class TestResultTest < TestCase
  def set_up
    @result = TestResult.new
  end

  def test_formats_failed_results
    @result.test_started
    @result.test_failed
    assert_equal @result.summary, '1 run, 1 failed'
  end

  def test_formats_errors
    @result.test_started
    @result.test_errored
    assert_equal @result.summary, '1 run, 0 failed, 1 error'
  end

  def test_succeeded
    @result.test_started
    assert(@result.succeeded?)
  end

  def test_fails_if_never_run
    assert(!@result.succeeded?)
  end

  def test_fails_if_there_is_a_failure
    @result.test_failed
    assert(!@result.succeeded?)
  end

  def test_fails_if_there_is_an_error
    @result.test_errored
    assert(!@result.succeeded?)
  end
end

class TestSuiteTest < TestCase
  def test_suite_runs_all_the_tests
    suite = TestSuite.new
    suite << WasRun
    result = suite.run
    assert_equal result.summary, '3 run, 1 failed, 1 error'
  end
end

class AssertionsTest < TestCase
  attr_accessor :probe

  def test_assert_truthiness
    begin
      assert(true)
    rescue
      @probe = :pinged
    end
    assert @probe.nil?
  end

  def test_assert_falsiness
    begin
      assert(false)
    rescue AssertionError
      @probe = :pinged
    end
    assert_equal @probe, :pinged
  end

  def test_message_on_fail
    begin
      assert(false, 'falsy')
    rescue AssertionError => e
      @probe = e.message
    end
    assert_equal @probe, "test_message_on_fail: falsy [FAIL]"
  end

  def test_assert_equality
    begin
      assert_equal(1, 1)
    rescue AssertionError
      @probe = :pinged
    end
    assert @probe.nil?, "assert_equality should not raise on equality"
  end

  def test_assert_inequality
    begin
      assert_equal 1, 0
    rescue AssertionError
      @probe = :pinged
    end
    assert @probe == :pinged, "assert_equality should raise on inequality"
  end

  def test_message_on_inequality
    begin
      assert_equal 1, 0, 'equality'
    rescue AssertionError => e
      @probe = e.message
    end
    assert_equal @probe, "test_message_on_inequality: 1 should have equaled 0: equality [FAIL]"
  end
end

suite = TestSuite.new
suite            <<
  TestCaseTest   <<
  TestResultTest <<
  TestSuiteTest  <<
  AssertionsTest

result = suite.run

puts result.summary

exit(result.succeeded? ? 0 : 1)