class WasRun
  attr_accessor :wasRun

  def initialize(test)
  end

  def testMethod
    self.wasRun = true
  end
end

test = WasRun.new('testMethod')
puts test.wasRun.inspect
test.testMethod
print test.wasRun.inspect
