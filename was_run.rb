class WasRun
  attr_reader :wasRun

  def initialize(test)
  end
end

test = WasRun.new('testMethod')
puts test.wasRun
test.testMethod
print test.wasRun
