# Assignment #1. Enumerable

In this assignment you will implement methods of the module
`Enumerable`. Let's do it for the current Ruby version that is 3.4.

Thorough specs (kudos to the ruby/spec project) are provided in the
`spec/enumerable` directory. The official documentation can be found
[here](https://docs.ruby-lang.org/en/3.4/Enumerable.html).

You can look at my solution in a `solution-assignment-1-enumerable` Git
branch where I implemented all the methods myself.


## Goal

A goal of this assignment is simple - to understand better how
Enumerable's methods work, become more familiar with edge cases, and
last but not least - have fun.

By no means performance and possible micro optimizations are expected or
supposed. Otherwise implementation in C would be more preferable.
Actually it can be a good additional task to re-implement the methods in
C as a Ruby native extension.

The goal of this guide (and specs as well) is providing additional
information that cannot be found in the official documentation and to
avoid looking at how it's done in Ruby (because it's implemented in C).


## Prerequisites

* familiarity with RSpec (a unit test linrary) to read provided unit
  tests


## Guide

Your implementation will be guided mostly by the documentation and the
specs. Here I will mention only some tricky issues and possible
solutions.


### A simplified example

There is no rocket sience behind Enumerable module methods logic. They
are pretty straightfoward to implement.

Let's look at the `#map` method. What it is doing is just a
transformation of a collection when each element is trancformed with a
logic defined in a block:

```ruby
[1, 2, 3].map { |e| e * 10 } # => [10, 20, 30]
```

The only method we can rely on to get our collection elements is
`#each`, so a simple implementation can look like the following:

```ruby
def map(&block)
  array = []

  each do |e|
    array << block.call(e)
  end

  array
end
```

Here we itarate over the collection elements, call a given block for
each of them and return a new Array with values returned by the block.

It's basically all what should be done. But the devil is in the detail
and there are a lot of them. Let's look at the most nasty ones in the
rest part of the guide.


### When a method called without a block

It is common for Enumerable's methods that accept a block (e.g. `#map`,
`#select` etc) to behave in a special way when they are called without a
it - they return Enumerator instead of raising an exception:

```ruby
[1, 2, 3].map
# => #<Enumerator: ...>
```

It's important to note that such enumerator iterates over a collection
of values that will be passed as arguments to a block, if it would be
specified. For instance the `#each_cons` and `#each_slice` produce a
sequence of arrays and pass them one by one to a block. When a block is
not given a returned enumerator iterates over this sequence of arrays:

```ruby
enum = [1, 2, 3, 4].each_slice(2)
enum.each { |slice| p slice }
# [1, 2]
# [3, 4]
```

One can say that it is a useless feature, but actually it allows to
materialize a way to iterate over a result collection. So this `enum`
can be passed somewhere else and will be treated as an ordinary
collection like `Array`. And it adds laziness.

To support this behavior an Enumerable's method should instantiate an
Enumerator object and return it when a block is not passed.

Enumerator can be created with a `new` method manually:

```ruby
fib = Enumerator.new do |y|
  a = b = 1
  loop do
    y << a
    a, b = b, a + b
  end
end
```

Or it can be created with helper methods Object#to_enum and
Object#enum_for. When they are called on a collection they create a new
Enumerator that iterates over the collection calling a `#each` method
(by default) or calling a method specified as an argument.

```ruby
string = "abc"

enum = string.enum_for(:each_char)
enum.each { |c| puts c }

# a
# b
# c
```

So returning an Enumerator becomes as simple as:

```ruby
def each_slice(n, &block)
  return to_enum(:each_slice, n) unless block

  # ...
end
```


### Setting Enumerator's size

When Enumerator iterates over a finit collection with predefined size
then `Enumerator#size` should return it as well.

The Enumerable's methods check whether a method `#size` is implemented
and use it to set an Enumerator's size.

The mehtods Object#to_enum and Object#enum_for accept optional size as a
result of a block passed to them.

```ruby
to_enum(:each_slice, n) { respond_to?(:size) ? size : nil }
```


### Handling optional parameters

Sometimes when a parameter is optional a method should distinguish
passing `nil` value and not passing that parameter at all.

For instance `Enumerable#first` accepts an optional parameter `n` -
number of first elements to return. It returns the first element when
called without parameters and raises TypeError when argument value is
`nil`:

```ruby
[1].to_enum.first
# => 1

[1].to_enum.first(nil)
# ... in `first': no implicit conversion from nil to integer (TypeError)
```

A common approach with `nil` as a default parameter value does not
work in this case:

```
def first(n = nil)
  ...
end
```

So we can use a really unique value instead of `nil` that nobody will pass as a
parameter. A private constant with value `Object.new` suits perfectly:

```ruby
UNDEFINED = Object.new
private_constant :UNDEFINED

def first(n = UNDEFINED)
  if n == UNDEFINED
    ...
  else
    ...
  end
end
```


### Type coercion

Some Enumerable's methods accept parameters, e.g. `#take` accepts number
of elements to return, `#inject` can be called with a method name etc.
Usually a specific type is expected so a parameter is implicitly
converted into it. Enumerable's methods expect Integer, Symbol, Hash,
other Enumerable and even pattern. Usually type convertion is performed
using methods like `#to_int`, `#to_hash` etc.

The logic is the following:
- return object itself if it's already of expected type
- raise `TypeError` if object is `nil`
- raise `TypeError` if object doesn't respond to a conversion method (e.g. `#to_int`)
- call the conversion method
- raise `TypeError` if returned value is not an instance of expected type
- return this value otherwise


### Numeric argument valid values range

Usually numeric parameters are either an index or number of elements.
Ruby assumes that such values fit into native integer types and raise
exception otherwise. The maximum value of such numeric value is 2**31 -
1.


### Yielding multiple values

In general case iterating over enumerable is a bit trickier than
iterating over collections like Array or Hash. A collection can be
generated dynamically with `yield` keyword and it adds some headache.

```ruby
class MyEnum
  include Enumerable

  def each
    yield 1
    yield 1, 2
    yield 1, 2, 3
  end
end
```

Let's exemine how Enumerable's methods handle such multiple yielding and
take a method `#select`:

```ruby
MyEnum.new.select do |e|
  p e
end

# 1
# [1, 2]
# [1, 2, 3]
```

So as we can see `#select` passes multiple yielded values as an Array.
But still pass a single yielded value as is.

How the method `#select` should call such `#each` method? Should it call
`#each` with a block with a single parameter?

```ruby
each do |e|
  p e
end
```

Or should it be a `*rest` parameter? Because it isn't known beforehand
what will be yielded single or multiple values.

Let's examine it and define two methods that use each approach - a
method `#select_single_parameter` uses single parameter and
`#select_rest_parameter` uses `*rest`. They don't implement semantic of
the `#select` method and used only to check the hypotesis.

```ruby
class MyEnum
  include Enumerable

  # definition of the #each method

  def select_single_parameter(&block)
    each do |e|
      block.call(e)
      # ... select logic here
    end
  end

  def select_rest_parameter(&block)
    each do |*els|
      block.call(els)
      # ... select logic here
    end
  end
end
```

Let's call them on the defined above `MyEnum`:

```ruby
MyEnum.new.select_single_parameter do |e|
  p e
end
# 1
# 1
# 1
```

```ruby
MyEnum.new.select_rest_parameter do |e|
  p e
end
# [1]
# [1, 2]
# [1, 2, 3]
```

With `#select_single_parameter` only the first element from the multiple
yielded ones is passed to a block.

With `#select_rest_parameter` everything looks good except the first
element - expected `1` but `[1]` was passed to a block.

A straightforward solution would be to accept `*rest` parameter and pass
it if there are multiple values but take the first element if there is
only one value:

```ruby
def select(&block)
  each do |*rest|
    if rest.size == 1
      yield rest[0]
    else
      yield rest
    end

    # ... select logic here
  end
end
```

This way we indeed get the correct result:

```ruby
MyEnum.new.select do |e|
  p e
end
# 1
# [1, 2]
# [1, 2, 3]
```


### Returning result lazily

Usually if an Enumerable's method produces a collection then it's
returned as an Array. But there are methods (e.g. `#chunk`) that return
result collection lazily, that's as Enumerator.

In this case the trick with `#to_enum` does not work and we should
manually create such Enumerator. Good question - why `#to_enum` isn't
helpful here?

Let's build an emumerator manually for method `#chunk` that divides
original Enumerable by subsequences using a block to find separator
elements (a block should return `false` on such elements). It's as
simple as calling method `new` and providing a block that will yield
values:

```ruby
def chunk
  # ...

  Enumerator.new do |y|
    y << 'foo'
  end
end
```

So we may build result collection eagerly and just yield its elements
using the Enumerator interface:

```ruby
def chunk
  chunks = []

  # build the result collection

  Enumerator.new do |y|
    chunks.each do |c|
      y << c
    end
  end
end
```

This satisfies the `#chunk` method semantic but this way returning
Enumerator is useless and doesn't bring any benefits. So let's build the
result lazily as well.

We need to iterate over the original Enumerable inside the Enumerator's
block. It seems easy because the block is evaluated in context of the
Enumerable so `self` is the original Enumerable and we can easily call
its `#each` method:

```ruby
def chunk
  Enumerator.new do |y|
    each do |e|
      # process each element
    end
  end
end
```

Implementing the `#chunk` method fully  is not iteresting for now but it
should finally call a block, passed to the method. Both explicitly
declared `&block` parameter and calling it with `yield` keyword work
inside the Enumerator's block:

```ruby
def chunk
  Enumerator.new do |y|
    each do |e|
      result = yield e

      # process block result
    end
  end
end
```

or

```ruby
def chunk(&block)
  Enumerator.new do |y|
    each do |e|
      result = block.call(e)

      # process block result
    end
  end
end
```


## If you still want to look at how Enumerable is implemented

The reference Enumerable implementation in Ruby located
[here](https://github.com/ruby/ruby/blob/v3_4_1/enum.c).

There are alternative Ruby implementations that might have more
readable implementations:

- TruffleRuby implements it in pure Ruby [here](https://github.com/oracle/truffleruby/blob/vm-ee-24.1.1/src/main/ruby/truffleruby/core/enumerable.rb)
- JRuby have it partially [in Ruby](https://github.com/jruby/jruby/blob/9.4.11.0/core/src/main/ruby/jruby/kernel/enumerable.rb) and [in Java](https://github.com/jruby/jruby/blob/9.4.11.0/core/src/main/java/org/jruby/RubyEnumerable.java)
- Natalie implements it in C++ [here](https://github.com/natalie-lang/natalie/blob/master/src/enumerable.rb)
- the honourable Rubinius implements it in pure Ruby as well [here](https://github.com/rubinius/rubinius/blob/master/core/enumerable.rb)
