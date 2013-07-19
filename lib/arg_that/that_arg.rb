class ThatArg
  def initialize(&blk)
    @blk = blk
  end

  def ==(other)
    @blk.call(other)
  end
end
