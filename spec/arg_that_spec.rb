require 'rspec'
require 'rspec/given'

require 'arg_that'

RSpec.configure do |config|
  config.include(ArgThat)
end

describe ArgThat do
  describe "using arg_that as a catch-all" do
    subject { Object.new }

    context "arg_that { true } always matches" do
      Then { expect(subject).to eqish arg_that { true } }
    end

    context "arg_that { false } never matches" do
      Then { expect(subject).to_not eqish arg_that { false } }
    end
  end

  describe "directly comparing a value with an arg_that matcher" do
    Then { expect(:foo).to eqish arg_that {|arg| arg.kind_of?(Symbol) } }
    Then { expect(:foo).to_not eqish arg_that {|arg| arg.kind_of?(String) } }
  end

  describe "comparing a value nestled in a collection with an arg_that matcher" do
    context "arrays" do
      Then { expect([5, 6, 1]).to eqish [5, 6, arg_that {|arg| arg < 2 }]}
      Then { expect([5, 6, 1]).to_not eqish [5, 6, arg_that {|arg| arg > 1 }]}
    end

    context "hashes" do
      Then do
        expect(
          :a => 1,
          :b => 99
        ).to eqish(
          :a => 1,
          :b => arg_that {|arg| arg > 98 && arg < 100 }
        )
      end

      Then do
        expect(
          :zip_code => 48176,
          :owner => "Fred Jim",
          :last_audit => Time.new(2012, 8, 12)
        ).to eqish(
          :zip_code => 48176,
          :owner => "Fred Jim",
          :last_audit => arg_that { |arg| arg > Time.new(2012, 1, 1) }
        )
      end

      Then do
        expect(
          :name => "Bob",
          :age => 28,
          :email => "bob@example.com",
          :created_at => Time.new(2013, 7, 18, 21, 40, 58)
        ).to eqish(
          :name => "Bob",
          :age => 28,
          :email => "bob@example.com",
          :created_at => arg_that { |arg| arg.kind_of?(Time) }
        )
      end
    end
  end

  describe "comparing custom types with an arg_that matcher" do
    context "a simple type" do
      class Dog
        def bark
          "wan wan"
        end
      end
      subject { Dog.new }
      When(:result) { subject.bark }
      Then { expect(result).to eqish arg_that { |arg| arg.include?("wan") } }
      And { expect(result).to_not eqish arg_that { |arg| arg.include?("woof") } }
    end

    context "a type that overrides ==" do
      class Cat
        def ==(other)
          false
        end

        def name
          "Gorbypuff"
        end
      end

      subject { Cat.new }
      Then { expect(subject).to eqish arg_that { |arg| arg.name == "Gorbypuff" }}
      Then { expect(subject).to_not eqish arg_that { |arg| arg.name == "Miles" }}
    end
  end
end

