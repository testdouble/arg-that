RSpec::Matchers.define :eqish do |expected|
  match do |actual|
    expected == actual
  end

  failure_message_for_should do |actual|
    RSpec::Matchers::BuiltIn::Eq.new(expected).
      tap {|eq| eq.matches?(actual) }.
      failure_message_for_should
  end

  failure_message_for_should_not do |actual|
    RSpec::Matchers::BuiltIn::Eq.new(expected).
      tap {|eq| eq.matches?(actual) }.
      failure_message_for_should_not
  end

  description do
    RSpec::Matchers::BuiltIn::Eq.new(expected).description
  end
end
