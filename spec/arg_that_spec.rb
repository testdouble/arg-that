require 'rspec'
require 'rspec/given'

require 'arg_that'

RSpec.configure do |config|
  config.include(ArgThat)
end

describe ArgThat do

  context "catch-all" do
    Then { 5.should == arg_that { true } }
    Then { 5.should_not == arg_that { false } }
  end

  context "direct value equality" do
    Then { 1.should == arg_that {|arg| arg.kind_of?(Fixnum) } }
    Then { 1.should_not == arg_that {|arg| arg.kind_of?(String) } }
  end

  context "a value inside something else" do
    Then { [5, 6, 1].should == [5, 6, arg_that {|arg| arg.kind_of?(Fixnum) }]}
    Then { [5, 6, 1].should_not == [5, 6, arg_that {|arg| arg > 1 }]}
    Then do
      {
        :a => 1,
        :b => 99
      }.should == {
        :a => 1,
        :b => arg_that {|arg| arg > 98 && arg < 100 }
      }
    end

    Then do
      {
        :zip_code => 48176,
        :owner => "Fred Jim",
        :last_audit => Time.new(2012, 8, 12)
      }.should == {
        :zip_code => 48176,
        :owner => "Fred Jim",
        :last_audit => arg_that { |arg| arg > Time.new(2012, 1, 1) }
      }
    end

    Then do
      {
        :name => "Bob",
        :age => 28,
        :email => "bob@example.com",
        :created_at => Time.new(2013, 7, 18, 21, 40, 58)
      }.should == {
        :name => "Bob",
        :age => 28,
        :email => "bob@example.com",
        :created_at => arg_that { |arg| arg.kind_of?(Time) }
      }
    end
  end

end
