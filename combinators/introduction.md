# Combinators (definition and examples)
There are many definitions of combinators but the one I like is functions that build programs from other programs. That's pretty high level so lets start with some simple examples:
```ruby
class Callable < Struct.new(:callable)

  def *(other_callable)
    Callable.new(lambda {|*args| [self.call(*args), other_callable.call(*args)]})
  end

  def call(*args)
    callable.call(*args)
  end

end
```

In the above class definition `*` is a combinator because it takes one program fragment, a callable instance, and combines it with another callable instance to create a third callable instance.
```ruby
f = Callable.new(lambda {|x| x * 2})
g = Callable.new(lambda {|x| x * 3})
(f * g).call(2) # ==> [4, 6]
```

So the general idea is quite simple. Start with simple building blocks and compose them with combinators to get the desired behavior. Fortunately for us we have already done the necessary groundwork to create the fundamental parsing building blocks and now we need the combinators for combining them.

Recall from last time the two classes that we had
```ruby
class Indexable

  attr_reader :current_position

  def initialize(input)
    @indexable, @current_position, @current_element = input, 0, input[0]
  end

  def advance!
    return nil unless old_element = @indexable[@current_position]
    @current_element = @indexable[@current_position += 1]
    old_element
  end

  def jump!(new_position)
    @current_position = new_position
  end

  def [](slice)
    @indexable[slice]
  end

end

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
```

Our focus is going to be `BasicParser` but to go further we need a place to put all our combinators. The simplest way to do that is to create a `Parser` superclass that all other parsers will inherit from.
```ruby
class Parser

  ## Combinators methods go here.

end

class BasicParser < Parser

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
```

# Splicing Two Parsers
So what is the simplest possible thing we can do with two `BasicParser` instances? Like the example in the beginning we can combine them in some way and the simplest possible way of combining two parsers is to run them one after the other. So if we have two parsers `a` and `b` then we can put them together in sequence and get a third parser `a > b`. `>` is our first combinator.
```ruby
class Parser

  def >(other)
    SequencedParser.new(self, other)
  end

end

class BasicParser < Parser

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

class SequencedParser < Parser

  def initialize(first, second)
    @parsers = [first, second]
  end

  def parse(indexable)
    i, accumulator = -1, []
    while (parser = @parsers[i += 1])
      result = parser.parse(indexable)
      if result[0] == :fail
        return result
      else
        accumulator += result
      end
    end
    return accumulator
  end

end
```

Notice what we are doing. We are creating a new instance that inherits from `Parser` and implements `parse`. The `parse` method for `SequencedParser` does exactly what its name suggests. It runs the two parsers in sequence and succeeds if and only if both parsers succeed and at the first sign of failure it bails and returns the failure results. You might be wondering how is sequencing two parsers different from just combining their matchers. That's a good guestion and you should run the following examples in `irb` to make sure you understand the difference:
```ruby
parser_a = (BasicParser.new([/[a-z]/]) > BasicParser.new([/[a-z]/]))
parser_b = BasicParser.new([/[a-z]/, /[a-z]/])
parser_a.parse(Indexable.new('abc'))
parser_b.parse(Indexable.new('abc'))
```

# Next Up
Study the examples in this section and make sure you understand the essence of what we are trying to do. I like to think of combinators as abstractions that take computational lego blocks and snaps them together to build ever more complicated structures except the way it all fits together still makes it easy for us to reason about the overall structure because we can always reduce everything inductively to the lowest level building blocks.
