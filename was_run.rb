class TestCase
  attr_reader :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  def run
    self.set_up
    self.public_send(@test_method)
  end

  def set_up
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
end

TestCaseTest.new('test_is_running').run
TestCaseTest.new('test_is_set_up').run
TestCaseTest.new('test_is_torn_down').run