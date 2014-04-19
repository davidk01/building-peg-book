class BasicParser

  def initialize(matchers)
    @matchers = matchers
  end

  def parse(indexable)
    index, start = -1, indexable.current_position
    while (m = @matchers[index += 1])
      next if m === indexable.advance!
      return [:fail, indexable[start...indexable.current_position - 1]]
    end
    [indexable[start...indexable.current_position]]
  end

end
