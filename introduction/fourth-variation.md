# Variation 4
So we have worked our way to a very minimal core for matching with sequences of elements that support `===` and `[]`. Now we just need to abstract the `parse` method into a parser object so that we can start combining different kinds of parser objects with parser combinator methods. Recall what we have from the previous section with the third variation:
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

def parse(matcher, indexable)
  index, start = -1, indexable.current_position
  while (m = matcher[index += 1])
    next if m === indexable.advance!
    return [:fail, indexable[start...indexable.current_position - 1]]
  end
  [indexable[start...indexable.current_position]]
end
```

There is no reason the `parse` method should be standing by itself. So let's abstract it into a class.

```ruby
class BasicParser

  def self.[](*matchers)
    new(matchers)
  end

  def initialize(matchers)
    @matcher = matchers
  end

  def parse(indexable)
    index, start = -1, indexable.current_position
    while (m = @matcher[index += 1])
      next if m === indexable.advance!
      return [:fail, indexable[start...indexable.current_position - 1]]
    end
    [indexable[start...indexable.current_position]]
  end

end
```

The examples from the previous section now become
```ruby
BasicParser.new([/[a-z]/]).parse(Indexable.new('abc'))
BasicParser.new([/[a-z]/, /[a-z]/]).parse(Indexable.new('abc'))
BasicParser.new([/[a-z]/, /[a-z]/, /[a-z]/]).parse(Indexable.new('abc'))
BasicParser.new('abc').parse(Indexable.new('abc'))
````

# What's Next
Now we almost have the entire foundation in place. Next we are going to add the combinator methods and some syntax sugar for simplifying the specification of the parsers so that we don't have to type `BasicParser` over and over again.
