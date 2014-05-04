class WasRun
  attr_accessor :wasRun
  attr_reader :test_method
  
  def initialize(test)
    @test_method = test
  end

  def run
    self.public_send(@test_method)
  end

  def testMethod
    self.wasRun = true
  end
end

test = WasRun.new('testMethod')
puts test.wasRun.inspect
test.run
print test.wasRun.inspect
