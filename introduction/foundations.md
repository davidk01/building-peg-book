# Foundations and Variation on a Theme
The foundations of any parsing technology are iteration and a matching relation. In other words, we need abstractions that support indexing and some form of matching. So I am going to assume we have objects that support `[]` and `===`, i.e. that is the interface on top of which we are going to build the rest of our abstractions. The reason I chose those symbols is because both arrays and strings support `[]` and act exactly as you would expect them to act. For arrays you get the n-th element and for strings you get the n-th character. The reason for `===` is a bit more obscure and has to do with how regular expressions work in Ruby. If you have a regular expression `e` and a string `s` then the expression `e === s` is `true` if the regular expression matches something in the string and `false` otherwise. For example, `/1/ === '45412'` will return `true` and `/1/ === '345'` will return `false`. Alright with the interface and the explanation for the reasons for the interface lets write some code to match one indexable object against another.

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
