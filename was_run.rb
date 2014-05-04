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

test = WasRun.new('testMethod')
puts test.wasRun.inspect
test.run
print test.wasRun.inspect
