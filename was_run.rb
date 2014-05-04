class TestCase
  attr_reader :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  def run
    self.public_send(@test_method)
  end
end

class WasRun < TestCase
  attr_accessor :wasRun

  def testMethod
    self.wasRun = true
  end
end

class TestCaseTest < TestCase
  def test_is_running
    test = WasRun.new('testMethod')
    raise unless !test.wasRun
    test.run
    raise unless test.wasRun
  end
end

TestCaseTest.new('test_is_running').run