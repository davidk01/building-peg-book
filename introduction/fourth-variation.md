# Variation 4
So we have worked our way to a very minimal core for matching with sequences of elements that support `===` and `[]`. Now we just need to abstract the `parse` method into a parser object so that we can start combining different kinds of parser objects with parser combinator methods. Recall what we have from the previous section with the third variation:
```ruby
REF : Variation 3
```

There is no reason the `parse` method should be standing by itself. So let's abstract it into a class.

```ruby
REF : Variation 4
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
