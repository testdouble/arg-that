require 'rspec'
require 'rspec/given'

require 'arg_that'

RSpec.configure do |config|
  config.include ArgThat
end

describe ArgThat do

  context "direct value equality" do
    Then { 1.should == arg_that {|arg| arg.kind_of?(Fixnum) } }
    Then { 1.should_not == arg_that {|arg| arg.kind_of?(String) } }
  end

  context "a value inside something else" do
    Then { [5, 6, 1].should == [5, 6, arg_that {|arg| arg.kind_of?(Fixnum) }]}
    Then { [5, 6, 1].should_not == [5, 6, arg_that {|arg| arg > 1 }]}
    Then do
      {:a => 1, :b => 99}.should == {
        :a => 1,
        :b => arg_that {|arg| arg > 98 && arg < 100 }
      }
    end
  end

end
