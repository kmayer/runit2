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
  attr_accessor :wasRun
  attr_accessor :log

  def initialize(*)
    super
    @log = []
  end

  def set_up
    @log << 'set_up'
  end

  def testMethod
    self.wasRun = true
  end
end

class TestCaseTest < TestCase
  attr_reader :test

  def set_up
    @test = WasRun.new('testMethod')
  end

  def test_is_running
    test.run
    raise unless test.wasRun
  end

  def test_is_set_up
    test.run
    raise unless test.log == ['set_up']
  end
end

TestCaseTest.new('test_is_running').run
TestCaseTest.new('test_is_set_up').run