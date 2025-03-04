## Guide

Start from #initialize and new_spec.rb. Implement #size before #each and
range_spec.rb. Implement #each before #first, #min, #max, #minmax.
Implement #to_a before #last(n)

`#each`
- return enumerator
- enumerator size


## Overriden Enumerable methods

Some methods actually are already implemented in some generic way in the
Enumerable module but are re-implemented in Range (e.g. such methods as
#min, #max, #minmax, #first, #include?, #count).

It's common for Range methods to handle Range specific edge cases, e.g. to
raise an exception if range is endless or beginingless so a generic
logic of an Enumerable method cannot be applied. For instance the
`#count` method called without a block and an argument on a beginless or
endless range just returns `Float::INFINITY` instead of raising
exception for beginingless range and infinit iteration for an endless
one (what would happen if `Enumerable#count` was just called without any
checks)

Moreover Range methods may have optimised implementations specific for
some range elements type. For instance `#count` called without block and
an argument on a range with Integer `begin` and `end` can just return
`end - begin + 1` without any iteration. And `#max` called without a
block and an argument on a range with Integer `end` can just return
`end` as a maximum element.


## Comparision with range boundaries

- excluded end
- not comparable

## #cover? and excluded end (use #max to get the rightmost value)

## #step and String/Symbol range (legacy behavior)

## #step and comparision of Float values

Use small epsilon to compare Float reault of computation with other
Float value.


## Implementation details
- #reverse_each can be simply delegated to Enumerable#reverse_each
- #to_a can be simply delegated to Enumerable#to_a
- #count can be simply delegated to Enumerable#count
- #minmax, #min, #max can be delegated to corresponding methods in
  Enumerable when block isn't given
- #bsearch in fact could work with any Numeric types (Rational, Complex,
  custom ones) but in Ruby it's implemented in a non-generic way and
  works only with Integer and Float ranges. So it's up to you whether to
  support any Numeric type or behave strictly like Ruby does and support
  only Integer and Float.
- when #bsearch called with an endless range it cannot use the usuall
  binary search because there is no right boundary. So it tries to
  find it. #bsearch is checking begin + 1, begin + 2, begin + 4 elements
  (that's begin + 2^i) to find the first one that satisfies a user
  defined (with a block) condition and uses it as the right boundary for
  binary search.
- when #bsearch called with a beginingless range it uses the same
  approach to find the left boundary. #bsearch is checking end - 1,
  begin - 2, begin - 4 elements (that's end - 2^i) to find the first one
  that doesn't satisfy a user defined (with a block) condition and uses it
  as the left boundary for binary search.


## Extra issues
- optimize #each for Integer and use #+ to iterate from a begin boundary instead of #succ
- optimize #reverse_each for Integer range by iterating with #- from an
  end boundary
- optimise #count for Integer ranges and calculate result without
  iterating range elements. Can it be generalized for any Numeric type?
- optimize #minmax, #min and #max for Integer and find minimum and
  maximum elements without iterating through a range elements. Can it be
  generalized for any Numeric type?
- optimize #last(n) for Integer ranges

- fix methods #==, #eql? and #inspect and protect them from recursive
  calling when either range's begin or end creates a cyclic dependency

Example:

```ruby
r = Range.allocate
r.send(:initialize, r, r)
r.inspect
# => "(... .. ...)..(... .. ...)"
```
- optimize #first and don't call #each to iterate range elements if
  called witn n = 1
- implement #bsearch for Float ranges

