class WasRun
  attr_reader :wasRun

  def initialize(test)
  end

  def testMethod
  end
end

test = WasRun.new('testMethod')
puts test.wasRun.inspect
test.testMethod
print test.wasRun.inspect
