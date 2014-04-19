# Combinators (definition and examples)
There are many definitions of combinators but the one I like is functions that build programs from other programs. That's pretty high level so lets start with a simple example:
```ruby
REF : Callable sample
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
REF : Indexable class

REF : Variation 4
```

Our focus is going to be `BasicParser` but to go further we need a place to put all our combinators. The simplest way to do that is to create a `Parser` superclass that all other parsers will inherit from.
```ruby
REF : Initial basic parser
```

# Splicing Two Parsers
So what is the simplest possible thing we can do with two `BasicParser` instances? Like the example in the beginning we can combine them in some way and the simplest possible way of combining two parsers is to run them one after the other. So if we have two parsers `a` and `b` then we can put them together in sequence and get a third parser `a > b`. `>` is our first combinator.
```ruby
REF : Initial basic parser

REF : Sequenced Parser
```

Notice what we are doing. We are creating a new instance that inherits from `Parser` and implements `parse`. The `parse` method for `SequencedParser` does exactly what its name suggests. It runs the two parsers in sequence and succeeds if and only if both parsers succeed and at the first sign of failure it bails and returns the failure results. You might be wondering how is sequencing two parsers different from just combining their matchers. That's a good guestion and you should run the following examples in `irb` to make sure you understand the difference:
```ruby
parser_a = (BasicParser.new([/[a-z]/]) > BasicParser.new([/[a-z]/]))
parser_b = BasicParser.new([/[a-z]/, /[a-z]/])
parser_a.parse(Indexable.new('abc'))
parser_b.parse(Indexable.new('abc'))
```

# Next Up
Study the examples in this section and make sure you understand the essence of what we are trying to do. I like to think of combinators as abstractions that take computational lego blocks and snaps them together to build ever more complicated structures. But the way we put everything together doesn't actual make things more complicated than necessary. It is all done in a way to make it easy for us to reason about the overall structure because we can always reduce everything inductively to the atomic building blocks which are simple enough to unerstand without much trouble.
