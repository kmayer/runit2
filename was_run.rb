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
  attr_accessor :wasSetup

  def set_up
    self.wasSetup = true
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
    raise unless !test.wasRun
    test.run
    raise unless test.wasRun
  end

  def test_is_set_up
    test.run
    raise unless test.wasSetup
  end
end

TestCaseTest.new('test_is_running').run
TestCaseTest.new('test_is_set_up').run