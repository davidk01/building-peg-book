# Making Choices
So far we haven't made any choices during parsing. All our parsers so far either succeed or fail. It's time we added the ability to make choices. If you are familiar with regular expressions then we are going to implement the analog of `/a|b/`.

# Alternated Parser
Recall from last time how we combined two basic parsers into a `SequencedParser`
```ruby
class SequencedParser < Parser

  def initialize(first, second)
    @parsers = [first, second]
  end

  def parse(indexable)
    i, accumulator = -1, []
    while (parser = @parsers[i += 1])
      result = parser.parse(indexable)
      if result[0] === :fail
        return result
      else
        accumulator += result
      end
    end
    return accumulator
  end

end
```

This pattern is going to keep coming up in various variation so study it until you are comfortable with it. The pattern being taking two parsers and combining them in some way to create a third parser. So without further ado here's our second combinator `|`. It is pronounced prioritized choice because it involves trying and re-trying until things succeed.
```ruby
class Parser

  def |(other)
    AlternatedParser.new(self, other)
  end

end

class AlternatedParser < Parser

  def initialize(first, second)
    @parsers = [first, second]
  end

  def parse(indexable)
    i, accumulator, start = -1, [], indexable.current_position
    while (parser = @parser[i += 1])
      result = parser.parse(indexable)
      return result unless result[0] === :fail
      indexable.jump!(start)
      accumulator += result
    end
    return [:fail, accumulator]
  end

end
```

In words, an instance of `AlternatedParser` tries to parse with each parser in turn. If there is a failure then we rewind the input stream to the position where we initially started before trying the next parser. Code is always easier so try the following examples to see what happens.
```ruby
parser = (BasicParser.new('a') > BasicParser.new('b')) | BasicParser.new('c')
parser.parse('abc')
parser.parse('ab')
parser.parse('cde')
parser.parse('def')
```
