class TestCase
  attr_reader :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  def run
    result = TestResult.new
    result.test_started
    self.set_up
    self.public_send(@test_method)
    self.tear_down
    result
  end

  def set_up
  end

  def tear_down
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
    raise
  end

  def tear_down
    @log << 'tear_down'
  end
end

class TestCaseTest < TestCase
  attr_reader :test

  def set_up
    @test = WasRun.new('testMethod')
  end

  def test_is_running
    test.run
    raise unless test.log.include?('testMethod')
  end

  def test_is_set_up
    test.run
    raise unless test.log.first == 'set_up'
  end

  def test_is_torn_down
    test.run
    raise unless test.log.last == 'tear_down'
  end

  def test_reports_results
    result = test.run
    raise unless result.summary == '1 run, 0 failed'
  end

  def test_formats_failed_results
    result = TestResult.new
    result.test_started
    result.test_failed
    raise unless result.summary == '1 run, 1 failed'
  end

  def test_reports_failed_results
    @test = WasRun.new('testBrokenMethod')
    result = test.run
    raise unless result.summary == '1 run, 1 failed'
  end
end

TestCaseTest.new('test_is_running').run
TestCaseTest.new('test_is_set_up').run
TestCaseTest.new('test_is_torn_down').run
TestCaseTest.new('test_reports_results').run
TestCaseTest.new('test_formats_failed_results').run
# TestCaseTest.new('test_reports_failed_results').run
