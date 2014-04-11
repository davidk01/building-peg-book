# Foundations and Variations on a Theme
The foundations of any parsing technology are iteration and a matching relation. In other words, we need abstractions that support indexing and some form of matching. So I am going to assume we have objects that support `[]` and `===`, i.e. that is the interface on top of which we are going to build the rest of our abstractions. The reason I chose those symbols is because both arrays and strings support `[]` and act exactly as you would expect them to act. For arrays you get the n-th element and for strings you get the n-th character. The reason for `===` is a bit more obscure and has to do with how regular expressions work in Ruby. If you have a regular expression `e` and a string `s` then the expression `e === s` is `true` if the regular expression matches something in the string and `false` otherwise. For example, `/1/ === '45412'` will return `true` and `/1/ === '345'` will return `false`. Let's jump into some code and start matching objects.

# Variation 1
```ruby
def parse(matcher, stream)
  index = 0
  for m in matcher
    if m === stream[index]
      index += 1
    else
      return [:fail, stream[0...index]]
    end
  end
  [stream[0..index]]
end
```

What is the intent of the above code? Basically we are verifying that all the pieces of `matcher` line up in the `stream` and then we return the piece of the stream that matched. If every component of the `matcher` lines up then the parsing attempt is successful and if not then we tag the result with `:fail` because we want to indicate some kind of failure. We could have also thrown an exception or returned `false`. We didn't do that because exceptions are going to kill performance and we didn't simply return `false` because when debugging we might want to know how far we got in the stream of things we were trying to match before failing. You should notice one important thing in the above code. We are cheating by using for everything should only depend on indexing with `[]`. That brings us to the second variation.

# Variation 2
```ruby
def parse(matcher, stream)
  index = -1
  while (m = matcher[index += 1])
    next if m === stream[index]
    return [:fail, stream[0...index]]
  end
  [stream[0...index]]
end
```

Now we only depend on indexing with `[]` and comparing things with `===`. Open up `irb` and try a few examples and see what happens. Here are some test cases to get you started:
```ruby
parse([/\d/], '123')
parse([/\d/, /\d/, /[a-z]/], '12a')
parse([/\d/, /\d/, /[a-z]/], '12bc')
parse([/\d/, /\d/, /[a-z]/], '12A')
```

Do a few more so you get a good feel for what exactly is going on and verify that there aren't any off-by-one errors. We are still missing something though because we have simplified things a little too much. When we start chaining parsers together we will need to keep track of where we are in the input stream. Right now we have confounded those two indices into one variable. So we need to abstract things a little bit.

# Variation 3
```ruby
class Indexable

  attr_reader :current_position

  def initialize(input)
    @indexable, @current_position, @current_element = input, 0, input[0]
  end

  def advance!
    old_element = @indexable[@current_position]
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

Now we are starting to get somewhere. Abstracting the input stream into a class allows us to keep a very minimal amount of state which is basically just a pointer into the indexable object that tells us where we are. All parsing now happens with the help of that pointer. Some examples to try out before we bring it all together in the fourth variation by abstracting the parser into its own class as well.
```ruby
parse([/[a-z]/], Indexable.new('abc'))
parse([/[a-z]/, /[a-z]/, /\d/], Indexable.new('abc'))
parse([/[a-z]/, /[a-z]/, /[a-z]/], Indexable.new('abc'))
parse('abc', Indexable.new('abc'))
```
Make sure you understand why the indexing and slicing is the way it is. It took me several tries and several examples in `irb` before I got it right. Once you are comfortable with the examples and the code in this section re-read the code one more time and then proceed to the fourth variation.
