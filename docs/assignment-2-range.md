Guide

Implementation details
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

Extra issues:
- optimize #each for Integer and use #+ to iterate from a begin boundary instead of #succ
- optimize #reverse_each for Integer range by iterating with #- from an
  end boundary
- fix methods #==, #eql? and #inspect and protect them from recursive
  calling when either range's begin or end creates a cyclic dependency
- optimise #count for Integer ranges and calculate result without
  iterating range elements. Can it be generalized for any Numeric type?
- optimize #minmax, #min and #max for Integer and find minimum and
  maximum elements without iterating through a range elements. Can it be
  generalized for any Numeric type?

Example:

```ruby
r = Range.allocate
r.send(:initialize, r, r)
r.inspect
# => "(... .. ...)..(... .. ...)"
```


TODO
- add helper class for empty Range
