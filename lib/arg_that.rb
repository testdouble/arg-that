require "arg_that/version"
require "arg_that/that_arg"

module ArgThat
  def arg_that(&blk)
    ThatArg.new(&blk)
  end
end
