require "arg_that/version"
require "arg_that/that_arg"

module ArgThat
  def arg_that(&blk)
    ThatArg.new(&blk)
  end

  def self.included(includer)
    if defined?(RSpec) && includer.ancestors.include?(RSpec::Core::ExampleGroup)
      require "arg_that/eqish"
    end
  end
end
