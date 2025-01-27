module BuildYourOwn
  module RubyCoreLibrary
    # Documentation from the Ruby Project
    module Enumerable
      #  call-seq:
      #    all?                  -> true or false
      #    all?(pattern)         -> true or false
      #    all? {|element| ... } -> true or false
      #
      #  Returns whether every element meets a given criterion.
      #
      #  If +self+ has no element, returns +true+ and argument or block
      #  are not used.
      #
      #  With no argument and no block,
      #  returns whether every element is truthy:
      #
      #    (1..4).all?           # => true
      #    %w[a b c d].all?      # => true
      #    [1, 2, nil].all?      # => false
      #    ['a','b', false].all? # => false
      #    [].all?               # => true
      #
      #  With argument +pattern+ and no block,
      #  returns whether for each element +element+,
      #  <tt>pattern === element</tt>:
      #
      #    (1..4).all?(Integer)                 # => true
      #    (1..4).all?(Numeric)                 # => true
      #    (1..4).all?(Float)                   # => false
      #    %w[bar baz bat bam].all?(/ba/)       # => true
      #    %w[bar baz bat bam].all?(/bar/)      # => false
      #    %w[bar baz bat bam].all?('ba')       # => false
      #    {foo: 0, bar: 1, baz: 2}.all?(Array) # => true
      #    {foo: 0, bar: 1, baz: 2}.all?(Hash)  # => false
      #    [].all?(Integer)                     # => true
      #
      #  With a block given, returns whether the block returns a truthy value
      #  for every element:
      #
      #    (1..4).all? {|element| element < 5 }                    # => true
      #    (1..4).all? {|element| element < 4 }                    # => false
      #    {foo: 0, bar: 1, baz: 2}.all? {|key, value| value < 3 } # => true
      #    {foo: 0, bar: 1, baz: 2}.all? {|key, value| value < 2 } # => false
      #
      #  Related: #any?, #none? #one?.
      def all?
      end

      #  call-seq:
      #    any?                  -> true or false
      #    any?(pattern)         -> true or false
      #    any? {|element| ... } -> true or false
      #
      #  Returns whether any element meets a given criterion.
      #
      #  If +self+ has no element, returns +false+ and argument or block
      #  are not used.
      #
      #  With no argument and no block,
      #  returns whether any element is truthy:
      #
      #    (1..4).any?          # => true
      #    %w[a b c d].any?     # => true
      #    [1, false, nil].any? # => true
      #    [].any?              # => false
      #
      #  With argument +pattern+ and no block,
      #  returns whether for any element +element+,
      #  <tt>pattern === element</tt>:
      #
      #    [nil, false, 0].any?(Integer)        # => true
      #    [nil, false, 0].any?(Numeric)        # => true
      #    [nil, false, 0].any?(Float)          # => false
      #    %w[bar baz bat bam].any?(/m/)        # => true
      #    %w[bar baz bat bam].any?(/foo/)      # => false
      #    %w[bar baz bat bam].any?('ba')       # => false
      #    {foo: 0, bar: 1, baz: 2}.any?(Array) # => true
      #    {foo: 0, bar: 1, baz: 2}.any?(Hash)  # => false
      #    [].any?(Integer)                     # => false
      #
      #  With a block given, returns whether the block returns a truthy value
      #  for any element:
      #
      #    (1..4).any? {|element| element < 2 }                    # => true
      #    (1..4).any? {|element| element < 1 }                    # => false
      #    {foo: 0, bar: 1, baz: 2}.any? {|key, value| value < 1 } # => true
      #    {foo: 0, bar: 1, baz: 2}.any? {|key, value| value < 0 } # => false
      #
      #  Related: #all?, #none?, #one?.
      def any?
      end

      # call-seq:
      #   e.chain(*enums) -> enumerator
      #
      # Returns an enumerator object generated from this enumerator and
      # given enumerables.
      #
      #   e = (1..3).chain([4, 5])
      #   e.to_a #=> [1, 2, 3, 4, 5]
      def chain
      end

      #  call-seq:
      #    chunk {|array| ... } -> enumerator
      #
      #  Each element in the returned enumerator is a 2-element array consisting of:
      #
      #  - A value returned by the block.
      #  - An array ("chunk") containing the element for which that value was returned,
      #    and all following elements for which the block returned the same value:
      #
      #  So that:
      #
      #  - Each block return value that is different from its predecessor
      #    begins a new chunk.
      #  - Each block return value that is the same as its predecessor
      #    continues the same chunk.
      #
      #  Example:
      #
      #    e = (0..10).chunk {|i| (i / 3).floor } # => #<Enumerator: ...>
      #    # The enumerator elements.
      #    e.next # => [0, [0, 1, 2]]
      #    e.next # => [1, [3, 4, 5]]
      #    e.next # => [2, [6, 7, 8]]
      #    e.next # => [3, [9, 10]]
      def chunk
      end

      #  call-seq:
      #     enum.chunk_while {|elt_before, elt_after| bool } -> an_enumerator
      #
      #  Creates an enumerator for each chunked elements.
      #  The beginnings of chunks are defined by the block.
      #
      #  This method splits each chunk using adjacent elements,
      #  _elt_before_ and _elt_after_,
      #  in the receiver enumerator.
      #  This method split chunks between _elt_before_ and _elt_after_ where
      #  the block returns <code>false</code>.
      #
      #  The block is called the length of the receiver enumerator minus one.
      #
      #  The result enumerator yields the chunked elements as an array.
      #  So +each+ method can be called as follows:
      #
      #    enum.chunk_while { |elt_before, elt_after| bool }.each { |ary| ... }
      #
      #  Other methods of the Enumerator class and Enumerable module,
      #  such as +to_a+, +map+, etc., are also usable.
      def chunk_while
      end

      #  call-seq:
      #    compact -> array
      #
      #  Returns an array of all non-+nil+ elements:
      #
      #    a = [nil, 0, nil, 'a', false, nil, false, nil, 'a', nil, 0, nil]
      #    a.compact # => [0, "a", false, false, "a", 0]
      def compact
      end

      # call-seq:
      #   count -> integer
      #   count(object) -> integer
      #   count {|element| ... } -> integer
      #
      # Returns the count of elements, based on an argument or block criterion, if given.
      #
      # With no argument and no block given, returns the number of elements:
      #
      #   [0, 1, 2].count                # => 3
      #   {foo: 0, bar: 1, baz: 2}.count # => 3
      #
      # With argument +object+ given,
      # returns the number of elements that are <tt>==</tt> to +object+:
      #
      #   [0, 1, 2, 1].count(1)           # => 2
      #
      # With a block given, calls the block with each element
      # and returns the number of elements for which the block returns a truthy value:
      #
      #   [0, 1, 2, 3].count {|element| element < 2}              # => 2
      #   {foo: 0, bar: 1, baz: 2}.count {|key, value| value < 2} # => 2
      def count
      end

      #  call-seq:
      #    cycle(n = nil) {|element| ...} ->  nil
      #    cycle(n = nil)                 ->  enumerator
      #
      #  When called with positive integer argument +n+ and a block,
      #  calls the block with each element, then does so again,
      #  until it has done so +n+ times; returns +nil+:
      #
      #    a = []
      #    (1..4).cycle(3) {|element| a.push(element) } # => nil
      #    a # => [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
      #    a = []
      #    ('a'..'d').cycle(2) {|element| a.push(element) }
      #    a # => ["a", "b", "c", "d", "a", "b", "c", "d"]
      #    a = []
      #    {foo: 0, bar: 1, baz: 2}.cycle(2) {|element| a.push(element) }
      #    a # => [[:foo, 0], [:bar, 1], [:baz, 2], [:foo, 0], [:bar, 1], [:baz, 2]]
      #
      #  If count is zero or negative, does not call the block.
      #
      #  When called with a block and +n+ is +nil+, cycles forever.
      #
      #  When no block is given, returns an Enumerator.
      def cycle
      end

      #  call-seq:
      #    drop(n) -> array
      #
      #  For positive integer +n+, returns an array containing
      #  all but the first +n+ elements:
      #
      #    r = (1..4)
      #    r.drop(3)  # => [4]
      #    r.drop(2)  # => [3, 4]
      #    r.drop(1)  # => [2, 3, 4]
      #    r.drop(0)  # => [1, 2, 3, 4]
      #    r.drop(50) # => []
      #
      #    h = {foo: 0, bar: 1, baz: 2, bat: 3}
      #    h.drop(2) # => [[:baz, 2], [:bat, 3]]
      def drop
      end

      #  call-seq:
      #    drop_while {|element| ... } -> array
      #    drop_while                  -> enumerator
      #
      #  Calls the block with successive elements as long as the block
      #  returns a truthy value;
      #  returns an array of all elements after that point:
      #
      #
      #    (1..4).drop_while{|i| i < 3 } # => [3, 4]
      #    h = {foo: 0, bar: 1, baz: 2}
      #    a = h.drop_while{|element| key, value = *element; value < 2 }
      #    a # => [[:baz, 2]]
      #
      #  With no block given, returns an Enumerator.
      def drop_while
      end

      #  call-seq:
      #    each_cons(n) { ... } ->  self
      #    each_cons(n)         ->  enumerator
      #
      #  Calls the block with each successive overlapped +n+-tuple of elements;
      #  returns +self+:
      #
      #    a = []
      #    (1..5).each_cons(3) {|element| a.push(element) }
      #    a # => [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
      #
      #    a = []
      #    h = {foo: 0,  bar: 1, baz: 2, bam: 3}
      #    h.each_cons(2) {|element| a.push(element) }
      #    a # => [[[:foo, 0], [:bar, 1]], [[:bar, 1], [:baz, 2]], [[:baz, 2], [:bam, 3]]]
      #
      #  With no block given, returns an Enumerator.
      def each_cons
      end

      #  call-seq:
      #    each_entry(*args) {|element| ... } -> self
      #    each_entry(*args)                  -> enumerator
      #
      #  Calls the given block with each element,
      #  converting multiple values from yield to an array; returns +self+:
      #
      #    a = []
      #    (1..4).each_entry {|element| a.push(element) } # => 1..4
      #    a # => [1, 2, 3, 4]
      #
      #    a = []
      #    h = {foo: 0, bar: 1, baz:2}
      #    h.each_entry {|element| a.push(element) }
      #    # => {:foo=>0, :bar=>1, :baz=>2}
      #    a # => [[:foo, 0], [:bar, 1], [:baz, 2]]
      #
      #    class Foo
      #      include Enumerable
      #      def each
      #        yield 1
      #        yield 1, 2
      #        yield
      #      end
      #    end
      #    Foo.new.each_entry {|yielded| p yielded }
      #
      #  Output:
      #
      #    1
      #    [1, 2]
      #    nil
      #
      #  With no block given, returns an Enumerator.
      def each_entry
      end

      #  call-seq:
      #    each_slice(n) { ... }  ->  self
      #    each_slice(n)          ->  enumerator
      #
      #  Calls the block with each successive disjoint +n+-tuple of elements;
      #  returns +self+:
      #
      #    a = []
      #    (1..10).each_slice(3) {|tuple| a.push(tuple) }
      #    a # => [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
      #
      #    a = []
      #    h = {foo: 0, bar: 1, baz: 2, bat: 3, bam: 4}
      #    h.each_slice(2) {|tuple| a.push(tuple) }
      #    a # => [[[:foo, 0], [:bar, 1]], [[:baz, 2], [:bat, 3]], [[:bam, 4]]]
      #
      #  With no block given, returns an Enumerator.
      def each_slice
      end

      #  call-seq:
      #    each_with_index(*args) {|element, i| ..... } -> self
      #    each_with_index(*args)                       -> enumerator
      #
      #  Invoke <tt>self.each</tt> with <tt>*args</tt>.
      #  With a block given, the block receives each element and its index;
      #  returns +self+:
      #
      #    h = {}
      #    (1..4).each_with_index {|element, i| h[element] = i } # => 1..4
      #    h # => {1=>0, 2=>1, 3=>2, 4=>3}
      #
      #    h = {}
      #    %w[a b c d].each_with_index {|element, i| h[element] = i }
      #    # => ["a", "b", "c", "d"]
      #    h # => {"a"=>0, "b"=>1, "c"=>2, "d"=>3}
      #
      #    a = []
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.each_with_index {|element, i| a.push([i, element]) }
      #    # => {:foo=>0, :bar=>1, :baz=>2}
      #    a # => [[0, [:foo, 0]], [1, [:bar, 1]], [2, [:baz, 2]]]
      #
      #  With no block given, returns an Enumerator.
      def each_with_index
      end

      #  call-seq:
      #    each_with_object(object) { |(*args), memo_object| ... }  ->  object
      #    each_with_object(object)                                 ->  enumerator
      #
      #  Calls the block once for each element, passing both the element
      #  and the given object:
      #
      #    (1..4).each_with_object([]) {|i, a| a.push(i**2) }
      #    # => [1, 4, 9, 16]
      #
      #    {foo: 0, bar: 1, baz: 2}.each_with_object({}) {|(k, v), h| h[v] = k }
      #    # => {0=>:foo, 1=>:bar, 2=>:baz}
      #
      #  With no block given, returns an Enumerator.
      def each_with_object
      end

      #  call-seq:
      #    to_a(*args) -> array
      #
      #  Returns an array containing the items in +self+:
      #
      #    (0..4).to_a # => [0, 1, 2, 3, 4]
      def entries
      end
      alias to_a entries

      # call-seq:
      #   filter_map {|element| ... } -> array
      #   filter_map -> enumerator
      #
      # Returns an array containing truthy elements returned by the block.
      #
      # With a block given, calls the block with successive elements;
      # returns an array containing each truthy value returned by the block:
      #
      #   (0..9).filter_map {|i| i * 2 if i.even? }                              # => [0, 4, 8, 12, 16]
      #   {foo: 0, bar: 1, baz: 2}.filter_map {|key, value| key if value.even? } # => [:foo, :baz]
      #
      # When no block given, returns an Enumerator.
      def filter_map
      end

      # call-seq:
      #   find_index(object) -> integer or nil
      #   find_index {|element| ... } -> integer or nil
      #   find_index -> enumerator
      #
      # Returns the index of the first element that meets a specified criterion,
      # or +nil+ if no such element is found.
      #
      # With argument +object+ given,
      # returns the index of the first element that is <tt>==</tt> +object+:
      #
      #   ['a', 'b', 'c', 'b'].find_index('b') # => 1
      #
      # With a block given, calls the block with successive elements;
      # returns the first element for which the block returns a truthy value:
      #
      #   ['a', 'b', 'c', 'b'].find_index {|element| element.start_with?('b') } # => 1
      #   {foo: 0, bar: 1, baz: 2}.find_index {|key, value| value > 1 }         # => 2
      #
      # With no argument and no block given, returns an Enumerator.
      def find_index
      end

      # call-seq:
      #   find(if_none_proc = nil) {|element| ... } -> object or nil
      #   find(if_none_proc = nil) -> enumerator
      #
      # Returns the first element for which the block returns a truthy value.
      #
      # With a block given, calls the block with successive elements of the collection;
      # returns the first element for which the block returns a truthy value:
      #
      #   (0..9).find {|element| element > 2}                # => 3
      #
      # If no such element is found, calls +if_none_proc+ and returns its return value.
      #
      #   (0..9).find(proc {false}) {|element| element > 12} # => false
      #   {foo: 0, bar: 1, baz: 2}.find {|key, value| key.start_with?('b') }            # => [:bar, 1]
      #   {foo: 0, bar: 1, baz: 2}.find(proc {[]}) {|key, value| key.start_with?('c') } # => []
      #
      # With no block given, returns an Enumerator.
      def find
      end
      alias detect find

      #  call-seq:
      #    first    -> element or nil
      #    first(n) -> array
      #
      #  Returns the first element or elements.
      #
      #  With no argument, returns the first element, or +nil+ if there is none:
      #
      #    (1..4).first                   # => 1
      #    %w[a b c].first                # => "a"
      #    {foo: 1, bar: 1, baz: 2}.first # => [:foo, 1]
      #    [].first                       # => nil
      #
      #  With integer argument +n+, returns an array
      #  containing the first +n+ elements that exist:
      #
      #    (1..4).first(2)                   # => [1, 2]
      #    %w[a b c d].first(3)              # => ["a", "b", "c"]
      #    %w[a b c d].first(50)             # => ["a", "b", "c", "d"]
      #    {foo: 1, bar: 1, baz: 2}.first(2) # => [[:foo, 1], [:bar, 1]]
      #    [].first(2)                       # => []
      def first
      end

      # call-seq:
      #   flat_map {|element| ... } -> array
      #   flat_map -> enumerator
      #
      # Returns an array of flattened objects returned by the block.
      #
      # With a block given, calls the block with successive elements;
      # returns a flattened array of objects returned by the block:
      #
      #   [0, 1, 2, 3].flat_map {|element| -element }                    # => [0, -1, -2, -3]
      #   [0, 1, 2, 3].flat_map {|element| [element, -element] }         # => [0, 0, 1, -1, 2, -2, 3, -3]
      #   [[0, 1], [2, 3]].flat_map {|e| e + [100] }                     # => [0, 1, 100, 2, 3, 100]
      #   {foo: 0, bar: 1, baz: 2}.flat_map {|key, value| [key, value] } # => [:foo, 0, :bar, 1, :baz, 2]
      #
      # With no block given, returns an Enumerator.
      #
      # Alias: #collect_concat.
      def flat_map
      end
      alias collect_concat flat_map

      #  call-seq:
      #    grep(pattern) -> array
      #    grep(pattern) {|element| ... } -> array
      #
      #  Returns an array of objects based elements of +self+ that match the given pattern.
      #
      #  With no block given, returns an array containing each element
      #  for which <tt>pattern === element</tt> is +true+:
      #
      #    a = ['foo', 'bar', 'car', 'moo']
      #    a.grep(/ar/)                   # => ["bar", "car"]
      #    (1..10).grep(3..8)             # => [3, 4, 5, 6, 7, 8]
      #    ['a', 'b', 0, 1].grep(Integer) # => [0, 1]
      #
      #  With a block given,
      #  calls the block with each matching element and returns an array containing each
      #  object returned by the block:
      #
      #    a = ['foo', 'bar', 'car', 'moo']
      #    a.grep(/ar/) {|element| element.upcase } # => ["BAR", "CAR"]
      #
      #  Related: #grep_v.
      def grep
      end

      # call-seq:
      #   grep_v(pattern) -> array
      #   grep_v(pattern) {|element| ... } -> array
      #
      # Returns an array of objects based on elements of +self+
      # that <em>don't</em> match the given pattern.
      #
      # With no block given, returns an array containing each element
      # for which <tt>pattern === element</tt> is +false+:
      #
      #   a = ['foo', 'bar', 'car', 'moo']
      #   a.grep_v(/ar/)                   # => ["foo", "moo"]
      #   (1..10).grep_v(3..8)             # => [1, 2, 9, 10]
      #   ['a', 'b', 0, 1].grep_v(Integer) # => ["a", "b"]
      #
      # With a block given,
      # calls the block with each non-matching element and returns an array containing each
      # object returned by the block:
      #
      #   a = ['foo', 'bar', 'car', 'moo']
      #   a.grep_v(/ar/) {|element| element.upcase } # => ["FOO", "MOO"]
      #
      # Related: #grep.
      def grep_v
      end

      #  call-seq:
      #    group_by {|element| ... } -> hash
      #    group_by                  -> enumerator
      #
      #  With a block given returns a hash:
      #
      #  - Each key is a return value from the block.
      #  - Each value is an array of those elements for which the block returned that key.
      #
      #  Examples:
      #
      #    g = (1..6).group_by {|i| i%3 }
      #    g # => {1=>[1, 4], 2=>[2, 5], 0=>[3, 6]}
      #    h = {foo: 0, bar: 1, baz: 0, bat: 1}
      #    g = h.group_by {|key, value| value }
      #    g # => {0=>[[:foo, 0], [:baz, 0]], 1=>[[:bar, 1], [:bat, 1]]}
      #
      #  With no block given, returns an Enumerator.
      def group_by
      end

      #  call-seq:
      #    include?(object) -> true or false
      #
      #  Returns whether for any element <tt>object == element</tt>:
      #
      #    (1..4).include?(2)                       # => true
      #    (1..4).include?(5)                       # => false
      #    (1..4).include?('2')                     # => false
      #    %w[a b c d].include?('b')                # => true
      #    %w[a b c d].include?('2')                # => false
      #    {foo: 0, bar: 1, baz: 2}.include?(:foo)  # => true
      #    {foo: 0, bar: 1, baz: 2}.include?('foo') # => false
      #    {foo: 0, bar: 1, baz: 2}.include?(0)     # => false
      def include?
      end
      alias member? include?

      #  call-seq:
      #    inject(symbol)                -> object
      #    inject(initial_value, symbol) -> object
      #    inject {|memo, value| ... }   -> object
      #    inject(initial_value) {|memo, value| ... } -> object
      #
      #  Returns the result of applying a reducer to an initial value and
      #  the first element of the Enumerable. It then takes the result and applies the
      #  function to it and the second element of the collection, and so on. The
      #  return value is the result returned by the final call to the function.
      #
      #  You can think of
      #
      #      [ a, b, c, d ].inject(i) { |r, v| fn(r, v) }
      #
      #  as being
      #
      #      fn(fn(fn(fn(i, a), b), c), d)
      #
      #  In a way the +inject+ function _injects_ the function
      #  between the elements of the enumerable.
      #
      #  +inject+ is aliased as +reduce+. You use it when you want to
      #  _reduce_ a collection to a single value.
      def inject
      end
      alias reduce inject

      # call-seq:
      #   e.lazy -> lazy_enumerator
      #
      # Returns an Enumerator::Lazy, which redefines most Enumerable
      # methods to postpone enumeration and enumerate values only on an
      # as-needed basis.
      def lazy
      end

      # call-seq:
      #   map {|element| ... } -> array
      #   map -> enumerator
      #
      # Returns an array of objects returned by the block.
      #
      # With a block given, calls the block with successive elements;
      # returns an array of the objects returned by the block:
      #
      #   (0..4).map {|i| i*i }                               # => [0, 1, 4, 9, 16]
      #   {foo: 0, bar: 1, baz: 2}.map {|key, value| value*2} # => [0, 2, 4]
      #
      # With no block given, returns an Enumerator.
      def map
      end
      alias collect map

      #  call-seq:
      #    max_by {|element| ... }    -> element
      #    max_by(n) {|element| ... } -> array
      #    max_by                     -> enumerator
      #    max_by(n)                  -> enumerator
      #
      #  Returns the elements for which the block returns the maximum values.
      #
      #  With a block given and no argument,
      #  returns the element for which the block returns the maximum value:
      #
      #    (1..4).max_by {|element| -element }                    # => 1
      #    %w[a b c d].max_by {|element| -element.ord }           # => "a"
      #    {foo: 0, bar: 1, baz: 2}.max_by {|key, value| -value } # => [:foo, 0]
      #    [].max_by {|element| -element }                        # => nil
      #
      #  With a block given and positive integer argument +n+ given,
      #  returns an array containing the +n+ elements
      #  for which the block returns maximum values:
      #
      #    (1..4).max_by(2) {|element| -element }
      #    # => [1, 2]
      #    %w[a b c d].max_by(2) {|element| -element.ord }
      #    # => ["a", "b"]
      #    {foo: 0, bar: 1, baz: 2}.max_by(2) {|key, value| -value }
      #    # => [[:foo, 0], [:bar, 1]]
      #    [].max_by(2) {|element| -element }
      #    # => []
      #
      #  Returns an Enumerator if no block is given.
      #
      #  Related: #max, #minmax, #min_by.
      def max_by
      end

      #  call-seq:
      #    max                  -> element
      #    max(n)               -> array
      #    max {|a, b| ... }    -> element
      #    max(n) {|a, b| ... } -> array
      #
      #  Returns the element with the maximum element according to a given criterion.
      #  The ordering of equal elements is indeterminate and may be unstable.
      #
      #  With no argument and no block, returns the maximum element,
      #  using the elements' own method <tt>#<=></tt> for comparison:
      #
      #    (1..4).max                   # => 4
      #    (-4..-1).max                 # => -1
      #    %w[d c b a].max              # => "d"
      #    {foo: 0, bar: 1, baz: 2}.max # => [:foo, 0]
      #    [].max                       # => nil
      #
      #  With positive integer argument +n+ given, and no block,
      #  returns an array containing the first +n+ maximum elements that exist:
      #
      #    (1..4).max(2)                   # => [4, 3]
      #    (-4..-1).max(2)                # => [-1, -2]
      #    %w[d c b a].max(2)              # => ["d", "c"]
      #    {foo: 0, bar: 1, baz: 2}.max(2) # => [[:foo, 0], [:baz, 2]]
      #    [].max(2)                       # => []
      #
      #  With a block given, the block determines the maximum elements.
      #  The block is called with two elements +a+ and +b+, and must return:
      #
      #  - A negative integer if <tt>a < b</tt>.
      #  - Zero if <tt>a == b</tt>.
      #  - A positive integer if <tt>a > b</tt>.
      #
      #  With a block given and no argument,
      #  returns the maximum element as determined by the block:
      #
      #    %w[xxx x xxxx xx].max {|a, b| a.size <=> b.size } # => "xxxx"
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.max {|pair1, pair2| pair1[1] <=> pair2[1] }     # => [:baz, 2]
      #    [].max {|a, b| a <=> b }                          # => nil
      #
      #  With a block given and positive integer argument +n+ given,
      #  returns an array containing the first +n+ maximum elements that exist,
      #  as determined by the block.
      #
      #    %w[xxx x xxxx xx].max(2) {|a, b| a.size <=> b.size } # => ["xxxx", "xxx"]
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.max(2) {|pair1, pair2| pair1[1] <=> pair2[1] }
      #    # => [[:baz, 2], [:bar, 1]]
      #    [].max(2) {|a, b| a <=> b }                          # => []
      #
      #  Related: #min, #minmax, #max_by.
      def max
      end

      #  call-seq:
      #    min_by {|element| ... }    -> element
      #    min_by(n) {|element| ... } -> array
      #    min_by                     -> enumerator
      #    min_by(n)                  -> enumerator
      #
      #  Returns the elements for which the block returns the minimum values.
      #
      #  With a block given and no argument,
      #  returns the element for which the block returns the minimum value:
      #
      #    (1..4).min_by {|element| -element }                    # => 4
      #    %w[a b c d].min_by {|element| -element.ord }           # => "d"
      #    {foo: 0, bar: 1, baz: 2}.min_by {|key, value| -value } # => [:baz, 2]
      #    [].min_by {|element| -element }                        # => nil
      #
      #  With a block given and positive integer argument +n+ given,
      #  returns an array containing the +n+ elements
      #  for which the block returns minimum values:
      #
      #    (1..4).min_by(2) {|element| -element }
      #    # => [4, 3]
      #    %w[a b c d].min_by(2) {|element| -element.ord }
      #    # => ["d", "c"]
      #    {foo: 0, bar: 1, baz: 2}.min_by(2) {|key, value| -value }
      #    # => [[:baz, 2], [:bar, 1]]
      #    [].min_by(2) {|element| -element }
      #    # => []
      #
      #  Returns an Enumerator if no block is given.
      #
      #  Related: #min, #minmax, #max_by.
      def min_by
      end

      #  call-seq:
      #    min                  -> element
      #    min(n)               -> array
      #    min {|a, b| ... }    -> element
      #    min(n) {|a, b| ... } -> array
      #
      #  Returns the element with the minimum element according to a given criterion.
      #  The ordering of equal elements is indeterminate and may be unstable.
      #
      #  With no argument and no block, returns the minimum element,
      #  using the elements' own method <tt>#<=></tt> for comparison:
      #
      #    (1..4).min                   # => 1
      #    (-4..-1).min                 # => -4
      #    %w[d c b a].min              # => "a"
      #    {foo: 0, bar: 1, baz: 2}.min # => [:bar, 1]
      #    [].min                       # => nil
      #
      #  With positive integer argument +n+ given, and no block,
      #  returns an array containing the first +n+ minimum elements that exist:
      #
      #    (1..4).min(2)                   # => [1, 2]
      #    (-4..-1).min(2)                 # => [-4, -3]
      #    %w[d c b a].min(2)              # => ["a", "b"]
      #    {foo: 0, bar: 1, baz: 2}.min(2) # => [[:bar, 1], [:baz, 2]]
      #    [].min(2)                       # => []
      #
      #  With a block given, the block determines the minimum elements.
      #  The block is called with two elements +a+ and +b+, and must return:
      #
      #  - A negative integer if <tt>a < b</tt>.
      #  - Zero if <tt>a == b</tt>.
      #  - A positive integer if <tt>a > b</tt>.
      #
      #  With a block given and no argument,
      #  returns the minimum element as determined by the block:
      #
      #    %w[xxx x xxxx xx].min {|a, b| a.size <=> b.size } # => "x"
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.min {|pair1, pair2| pair1[1] <=> pair2[1] } # => [:foo, 0]
      #    [].min {|a, b| a <=> b }                          # => nil
      #
      #  With a block given and positive integer argument +n+ given,
      #  returns an array containing the first +n+ minimum elements that exist,
      #  as determined by the block.
      #
      #    %w[xxx x xxxx xx].min(2) {|a, b| a.size <=> b.size } # => ["x", "xx"]
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.min(2) {|pair1, pair2| pair1[1] <=> pair2[1] }
      #    # => [[:foo, 0], [:bar, 1]]
      #    [].min(2) {|a, b| a <=> b }                          # => []
      #
      #  Related: #min_by, #minmax, #max.
      def min
      end

      #  call-seq:
      #    minmax_by {|element| ... } -> [minimum, maximum]
      #    minmax_by                  -> enumerator
      #
      #  Returns a 2-element array containing the elements
      #  for which the block returns minimum and maximum values:
      #
      #    (1..4).minmax_by {|element| -element }
      #    # => [4, 1]
      #    %w[a b c d].minmax_by {|element| -element.ord }
      #    # => ["d", "a"]
      #    {foo: 0, bar: 1, baz: 2}.minmax_by {|key, value| -value }
      #    # => [[:baz, 2], [:foo, 0]]
      #    [].minmax_by {|element| -element }
      #    # => [nil, nil]
      #
      #  Returns an Enumerator if no block is given.
      #
      #  Related: #max_by, #minmax, #min_by.
      def minmax_by
      end

      #  call-seq:
      #    minmax               -> [minimum, maximum]
      #    minmax {|a, b| ... } -> [minimum, maximum]
      #
      #  Returns a 2-element array containing the minimum and maximum elements
      #  according to a given criterion.
      #  The ordering of equal elements is indeterminate and may be unstable.
      #
      #  With no argument and no block, returns the minimum and maximum elements,
      #  using the elements' own method <tt>#<=></tt> for comparison:
      #
      #    (1..4).minmax                   # => [1, 4]
      #    (-4..-1).minmax                 # => [-4, -1]
      #    %w[d c b a].minmax              # => ["a", "d"]
      #    {foo: 0, bar: 1, baz: 2}.minmax # => [[:bar, 1], [:foo, 0]]
      #    [].minmax                       # => [nil, nil]
      #
      #  With a block given, returns the minimum and maximum elements
      #  as determined by the block:
      #
      #    %w[xxx x xxxx xx].minmax {|a, b| a.size <=> b.size } # => ["x", "xxxx"]
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.minmax {|pair1, pair2| pair1[1] <=> pair2[1] }
      #    # => [[:foo, 0], [:baz, 2]]
      #    [].minmax {|a, b| a <=> b }                          # => [nil, nil]
      #
      #  Related: #min, #max, #minmax_by.
      def minmax
      end

      #  call-seq:
      #    none?                  -> true or false
      #    none?(pattern)         -> true or false
      #    none? {|element| ... } -> true or false
      #
      #  Returns whether no element meets a given criterion.
      #
      #  With no argument and no block,
      #  returns whether no element is truthy:
      #
      #    (1..4).none?           # => false
      #    [nil, false].none?     # => true
      #    {foo: 0}.none?         # => false
      #    {foo: 0, bar: 1}.none? # => false
      #    [].none?               # => true
      #
      #  With argument +pattern+ and no block,
      #  returns whether for no element +element+,
      #  <tt>pattern === element</tt>:
      #
      #    [nil, false, 1.1].none?(Integer)      # => true
      #    %w[bar baz bat bam].none?(/m/)        # => false
      #    %w[bar baz bat bam].none?(/foo/)      # => true
      #    %w[bar baz bat bam].none?('ba')       # => true
      #    {foo: 0, bar: 1, baz: 2}.none?(Hash)  # => true
      #    {foo: 0}.none?(Array)                 # => false
      #    [].none?(Integer)                     # => true
      #
      #  With a block given, returns whether the block returns a truthy value
      #  for no element:
      #
      #    (1..4).none? {|element| element < 1 }                     # => true
      #    (1..4).none? {|element| element < 2 }                     # => false
      #    {foo: 0, bar: 1, baz: 2}.none? {|key, value| value < 0 }  # => true
      #    {foo: 0, bar: 1, baz: 2}.none? {|key, value| value < 1 } # => false
      #
      #  Related: #one?, #all?, #any?.
      def none?
      end

      #  call-seq:
      #    one?                  -> true or false
      #    one?(pattern)         -> true or false
      #    one? {|element| ... } -> true or false
      #
      #  Returns whether exactly one element meets a given criterion.
      #
      #  With no argument and no block,
      #  returns whether exactly one element is truthy:
      #
      #    (1..1).one?           # => true
      #    [1, nil, false].one?  # => true
      #    (1..4).one?           # => false
      #    {foo: 0}.one?         # => true
      #    {foo: 0, bar: 1}.one? # => false
      #    [].one?               # => false
      #
      #  With argument +pattern+ and no block,
      #  returns whether for exactly one element +element+,
      #  <tt>pattern === element</tt>:
      #
      #    [nil, false, 0].one?(Integer)        # => true
      #    [nil, false, 0].one?(Numeric)        # => true
      #    [nil, false, 0].one?(Float)          # => false
      #    %w[bar baz bat bam].one?(/m/)        # => true
      #    %w[bar baz bat bam].one?(/foo/)      # => false
      #    %w[bar baz bat bam].one?('ba')       # => false
      #    {foo: 0, bar: 1, baz: 2}.one?(Array) # => false
      #    {foo: 0}.one?(Array)                 # => true
      #    [].one?(Integer)                     # => false
      #
      #  With a block given, returns whether the block returns a truthy value
      #  for exactly one element:
      #
      #    (1..4).one? {|element| element < 2 }                     # => true
      #    (1..4).one? {|element| element < 1 }                     # => false
      #    {foo: 0, bar: 1, baz: 2}.one? {|key, value| value < 1 }  # => true
      #    {foo: 0, bar: 1, baz: 2}.one? {|key, value| value < 2 } # => false
      #
      #  Related: #none?, #all?, #any?.
      def one?
      end

      #  call-seq:
      #    partition {|element| ... } -> [true_array, false_array]
      #    partition -> enumerator
      #
      #  With a block given, returns an array of two arrays:
      #
      #  - The first having those elements for which the block returns a truthy value.
      #  - The other having all other elements.
      #
      #  Examples:
      #
      #    p = (1..4).partition {|i| i.even? }
      #    p # => [[2, 4], [1, 3]]
      #    p = ('a'..'d').partition {|c| c < 'c' }
      #    p # => [["a", "b"], ["c", "d"]]
      #    h = {foo: 0, bar: 1, baz: 2, bat: 3}
      #    p = h.partition {|key, value| key.start_with?('b') }
      #    p # => [[[:bar, 1], [:baz, 2], [:bat, 3]], [[:foo, 0]]]
      #    p = h.partition {|key, value| value < 2 }
      #    p # => [[[:foo, 0], [:bar, 1]], [[:baz, 2], [:bat, 3]]]
      #
      #  With no block given, returns an Enumerator.
      #
      #  Related: Enumerable#group_by.
      def partition
      end

      # call-seq:
      #   reject {|element| ... } -> array
      #   reject -> enumerator
      #
      # Returns an array of objects rejected by the block.
      #
      # With a block given, calls the block with successive elements;
      # returns an array of those elements for which the block returns +nil+ or +false+:
      #
      #   (0..9).reject {|i| i * 2 if i.even? }                             # => [1, 3, 5, 7, 9]
      #   {foo: 0, bar: 1, baz: 2}.reject {|key, value| key if value.odd? } # => {:foo=>0, :baz=>2}
      #
      # When no block given, returns an Enumerator.
      #
      # Related: #select.
      def reject
      end

      #  call-seq:
      #    reverse_each(*args) {|element| ... } ->  self
      #    reverse_each(*args)                  ->  enumerator
      #
      #  With a block given, calls the block with each element,
      #  but in reverse order; returns +self+:
      #
      #    a = []
      #    (1..4).reverse_each {|element| a.push(-element) } # => 1..4
      #    a # => [-4, -3, -2, -1]
      #
      #    a = []
      #    %w[a b c d].reverse_each {|element| a.push(element) }
      #    # => ["a", "b", "c", "d"]
      #    a # => ["d", "c", "b", "a"]
      #
      #    a = []
      #    h.reverse_each {|element| a.push(element) }
      #    # => {:foo=>0, :bar=>1, :baz=>2}
      #    a # => [[:baz, 2], [:bar, 1], [:foo, 0]]
      #
      #  With no block given, returns an Enumerator.
      def reverse_each
      end

      # call-seq:
      #   select {|element| ... } -> array
      #   select -> enumerator
      #
      # Returns an array containing elements selected by the block.
      #
      # With a block given, calls the block with successive elements;
      # returns an array of those elements for which the block returns a truthy value:
      #
      #   (0..9).select {|element| element % 3 == 0 } # => [0, 3, 6, 9]
      #   a = {foo: 0, bar: 1, baz: 2}.select {|key, value| key.start_with?('b') }
      #   a # => {:bar=>1, :baz=>2}
      #
      # With no block given, returns an Enumerator.
      #
      # Related: #reject.
      def select
      end
      alias find_all select
      alias filter select

      #  call-seq:
      #     enum.slice_after(pattern)       -> an_enumerator
      #     enum.slice_after { |elt| bool } -> an_enumerator
      #
      #  Creates an enumerator for each chunked elements.
      #  The ends of chunks are defined by _pattern_ and the block.
      #
      #  If <code>_pattern_ === _elt_</code> returns <code>true</code> or the block
      #  returns <code>true</code> for the element, the element is end of a
      #  chunk.
      #
      #  The <code>===</code> and _block_ is called from the first element to the last
      #  element of _enum_.
      #
      #  The result enumerator yields the chunked elements as an array.
      #  So +each+ method can be called as follows:
      #
      #    enum.slice_after(pattern).each { |ary| ... }
      #    enum.slice_after { |elt| bool }.each { |ary| ... }
      #
      #  Other methods of the Enumerator class and Enumerable module,
      #  such as +map+, etc., are also usable.
      def slice_after
      end

      #  call-seq:
      #    slice_before(pattern)       -> enumerator
      #    slice_before {|elt| ... } -> enumerator
      #
      #  With argument +pattern+, returns an enumerator that uses the pattern
      #  to partition elements into arrays ("slices").
      #  An element begins a new slice if <tt>element === pattern</tt>
      #  (or if it is the first element).
      #
      #    a = %w[foo bar fop for baz fob fog bam foy]
      #    e = a.slice_before(/ba/) # => #<Enumerator: ...>
      #    e.each {|array| p array }
      #
      #  Output:
      #
      #    ["foo"]
      #    ["bar", "fop", "for"]
      #    ["baz", "fob", "fog"]
      #    ["bam", "foy"]
      #
      #  With a block, returns an enumerator that uses the block
      #  to partition elements into arrays.
      #  An element begins a new slice if its block return is a truthy value
      #  (or if it is the first element):
      #
      #    e = (1..20).slice_before {|i| i % 4 == 2 } # => #<Enumerator: ...>
      #    e.each {|array| p array }
      #
      #  Output:
      #
      #    [1]
      #    [2, 3, 4, 5]
      #    [6, 7, 8, 9]
      #    [10, 11, 12, 13]
      #    [14, 15, 16, 17]
      #    [18, 19, 20]
      #
      #  Other methods of the Enumerator class and Enumerable module,
      #  such as +to_a+, +map+, etc., are also usable.
      def slice_before
      end

      #  call-seq:
      #     enum.slice_when {|elt_before, elt_after| bool } -> an_enumerator
      #
      #  Creates an enumerator for each chunked elements.
      #  The beginnings of chunks are defined by the block.
      #
      #  This method splits each chunk using adjacent elements,
      #  _elt_before_ and _elt_after_,
      #  in the receiver enumerator.
      #  This method split chunks between _elt_before_ and _elt_after_ where
      #  the block returns <code>true</code>.
      #
      #  The block is called the length of the receiver enumerator minus one.
      #
      #  The result enumerator yields the chunked elements as an array.
      #  So +each+ method can be called as follows:
      #
      #    enum.slice_when { |elt_before, elt_after| bool }.each { |ary| ... }
      #
      #  Other methods of the Enumerator class and Enumerable module,
      #  such as +to_a+, +map+, etc., are also usable.
      def slice_when
      end

      #  call-seq:
      #    sort_by {|element| ... } -> array
      #    sort_by                  -> enumerator
      #
      #  With a block given, returns an array of elements of +self+,
      #  sorted according to the value returned by the block for each element.
      #  The ordering of equal elements is indeterminate and may be unstable.
      #
      #  Examples:
      #
      #    a = %w[xx xxx x xxxx]
      #    a.sort_by {|s| s.size }        # => ["x", "xx", "xxx", "xxxx"]
      #    a.sort_by {|s| -s.size }       # => ["xxxx", "xxx", "xx", "x"]
      #    h = {foo: 2, bar: 1, baz: 0}
      #    h.sort_by{|key, value| value } # => [[:baz, 0], [:bar, 1], [:foo, 2]]
      #    h.sort_by{|key, value| key }   # => [[:bar, 1], [:baz, 0], [:foo, 2]]
      #
      #  With no block given, returns an Enumerator.
      def sort_by
      end

      #  call-seq:
      #    sort               -> array
      #    sort {|a, b| ... } -> array
      #
      #  Returns an array containing the sorted elements of +self+.
      #  The ordering of equal elements is indeterminate and may be unstable.
      #
      #  With no block given, the sort compares
      #  using the elements' own method <tt>#<=></tt>:
      #
      #    %w[b c a d].sort              # => ["a", "b", "c", "d"]
      #    {foo: 0, bar: 1, baz: 2}.sort # => [[:bar, 1], [:baz, 2], [:foo, 0]]
      #
      #  With a block given, comparisons in the block determine the ordering.
      #  The block is called with two elements +a+ and +b+, and must return:
      #
      #  - A negative integer if <tt>a < b</tt>.
      #  - Zero if <tt>a == b</tt>.
      #  - A positive integer if <tt>a > b</tt>.
      #
      #  Examples:
      #
      #     a = %w[b c a d]
      #     a.sort {|a, b| b <=> a } # => ["d", "c", "b", "a"]
      #     h = {foo: 0, bar: 1, baz: 2}
      #     h.sort {|a, b| b <=> a } # => [[:foo, 0], [:baz, 2], [:bar, 1]]
      #
      #  See also #sort_by. It implements a Schwartzian transform
      #  which is useful when key computation or comparison is expensive.
      def sort
      end

      #  call-seq:
      #    sum(initial_value = 0)                  -> number
      #    sum(initial_value = 0) {|element| ... } -> object
      #
      #  With no block given,
      #  returns the sum of +initial_value+ and the elements:
      #
      #    (1..100).sum          # => 5050
      #    (1..100).sum(1)       # => 5051
      #    ('a'..'d').sum('foo') # => "fooabcd"
      #
      #  Generally, the sum is computed using methods <tt>+</tt> and +each+;
      #  for performance optimizations, those methods may not be used,
      #  and so any redefinition of those methods may not have effect here.
      #
      #  One such optimization: When possible, computes using Gauss's summation
      #  formula <em>n(n+1)/2</em>:
      #
      #    100 * (100 + 1) / 2 # => 5050
      #
      #  With a block given, calls the block with each element;
      #  returns the sum of +initial_value+ and the block return values:
      #
      #    (1..4).sum {|i| i*i }                        # => 30
      #    (1..4).sum(100) {|i| i*i }                   # => 130
      #    h = {a: 0, b: 1, c: 2, d: 3, e: 4, f: 5}
      #    h.sum {|key, value| value.odd? ? value : 0 } # => 9
      #    ('a'..'f').sum('x') {|c| c < 'd' ? c : '' }  # => "xabc"
      def sum
      end

      #  call-seq:
      #    take(n) -> array
      #
      #  For non-negative integer +n+, returns the first +n+ elements:
      #
      #    r = (1..4)
      #    r.take(2) # => [1, 2]
      #    r.take(0) # => []
      #
      #    h = {foo: 0, bar: 1, baz: 2, bat: 3}
      #    h.take(2) # => [[:foo, 0], [:bar, 1]]
      def take
      end

      #  call-seq:
      #    take_while {|element| ... } -> array
      #    take_while                  -> enumerator
      #
      #  Calls the block with successive elements as long as the block
      #  returns a truthy value;
      #  returns an array of all elements up to that point:
      #
      #
      #    (1..4).take_while{|i| i < 3 } # => [1, 2]
      #    h = {foo: 0, bar: 1, baz: 2}
      #    h.take_while{|element| key, value = *element; value < 2 }
      #    # => [[:foo, 0], [:bar, 1]]
      #
      #  With no block given, returns an Enumerator.
      def take_while
      end

      #  call-seq:
      #    tally(hash = {}) -> hash
      #
      #  When argument +hash+ is not given,
      #  returns a new hash whose keys are the distinct elements in +self+;
      #  each integer value is the count of occurrences of each element:
      #
      #    %w[a b c b c a c b].tally # => {"a"=>2, "b"=>3, "c"=>3}
      #
      #  When argument +hash+ is given,
      #  returns +hash+, possibly augmented; for each element +ele+ in +self+:
      #
      #  - Adds it as a key with a zero value if that key does not already exist:
      #
      #      hash[ele] = 0 unless hash.include?(ele)
      #
      #  - Increments the value of key +ele+:
      #
      #      hash[ele] += 1
      #
      #  This is useful for accumulating tallies across multiple enumerables:
      #
      #    h = {}                   # => {}
      #    %w[a c d b c a].tally(h) # => {"a"=>2, "c"=>2, "d"=>1, "b"=>1}
      #    %w[b a z].tally(h)       # => {"a"=>3, "c"=>2, "d"=>1, "b"=>2, "z"=>1}
      #    %w[b a m].tally(h)       # => {"a"=>4, "c"=>2, "d"=>1, "b"=>3, "z"=>1, "m"=>1}
      #
      #  The key to be added or found for an element depends on the class of +self+;
      #  see {Enumerable in Ruby Classes}[rdoc-ref:Enumerable@Enumerable+in+Ruby+Classes].
      #
      #  Examples:
      #
      #  - Array (and certain array-like classes):
      #    the key is the element (as above).
      #  - Hash (and certain hash-like classes):
      #    the key is the 2-element array formed from the key-value pair:
      #
      #      h = {}                        # => {}
      #      {foo: 'a', bar: 'b'}.tally(h) # => {[:foo, "a"]=>1, [:bar, "b"]=>1}
      #      {foo: 'c', bar: 'd'}.tally(h) # => {[:foo, "a"]=>1, [:bar, "b"]=>1, [:foo, "c"]=>1, [:bar, "d"]=>1}
      #      {foo: 'a', bar: 'b'}.tally(h) # => {[:foo, "a"]=>2, [:bar, "b"]=>2, [:foo, "c"]=>1, [:bar, "d"]=>1}
      #      {foo: 'c', bar: 'd'}.tally(h) # => {[:foo, "a"]=>2, [:bar, "b"]=>2, [:foo, "c"]=>2, [:bar, "d"]=>2}
      def tally
      end

      #  call-seq:
      #    to_h(*args) -> hash
      #    to_h(*args) {|element| ... }  -> hash
      #
      #  When +self+ consists of 2-element arrays,
      #  returns a hash each of whose entries is the key-value pair
      #  formed from one of those arrays:
      #
      #    [[:foo, 0], [:bar, 1], [:baz, 2]].to_h # => {:foo=>0, :bar=>1, :baz=>2}
      #
      #  When a block is given, the block is called with each element of +self+;
      #  the block should return a 2-element array which becomes a key-value pair
      #  in the returned hash:
      #
      #    (0..3).to_h {|i| [i, i ** 2]} # => {0=>0, 1=>1, 2=>4, 3=>9}
      #
      #  Raises an exception if an element of +self+ is not a 2-element array,
      #  and a block is not passed.
      def to_h
      end

      # Makes a set from the enumerable object with given arguments.
      def to_set
      end

      #  call-seq:
      #    uniq                  -> array
      #    uniq {|element| ... } -> array
      #
      #  With no block, returns a new array containing only unique elements;
      #  the array has no two elements +e0+ and +e1+ such that <tt>e0.eql?(e1)</tt>:
      #
      #    %w[a b c c b a a b c].uniq       # => ["a", "b", "c"]
      #    [0, 1, 2, 2, 1, 0, 0, 1, 2].uniq # => [0, 1, 2]
      #
      #  With a block, returns a new array containing elements only for which the block
      #  returns a unique value:
      #
      #    a = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1]
      #    a.uniq {|i| i.even? ? i : 0 } # => [0, 2, 4]
      #    a = %w[a b c d e e d c b a a b c d e]
      #    a.uniq {|c| c < 'c' }         # => ["a", "c"]
      def uniq
      end

      #  call-seq:
      #    zip(*other_enums) -> array
      #    zip(*other_enums) {|array| ... } -> nil
      #
      #  With no block given, returns a new array +new_array+ of size self.size
      #  whose elements are arrays.
      #  Each nested array <tt>new_array[n]</tt>
      #  is of size <tt>other_enums.size+1</tt>, and contains:
      #
      #  - The +n+-th element of self.
      #  - The +n+-th element of each of the +other_enums+.
      #
      #  If all +other_enums+ and self are the same size,
      #  all elements are included in the result, and there is no +nil+-filling:
      #
      #    a = [:a0, :a1, :a2, :a3]
      #    b = [:b0, :b1, :b2, :b3]
      #    c = [:c0, :c1, :c2, :c3]
      #    d = a.zip(b, c)
      #    d # => [[:a0, :b0, :c0], [:a1, :b1, :c1], [:a2, :b2, :c2], [:a3, :b3, :c3]]
      #
      #    f = {foo: 0, bar: 1, baz: 2}
      #    g = {goo: 3, gar: 4, gaz: 5}
      #    h = {hoo: 6, har: 7, haz: 8}
      #    d = f.zip(g, h)
      #    d # => [
      #      #      [[:foo, 0], [:goo, 3], [:hoo, 6]],
      #      #      [[:bar, 1], [:gar, 4], [:har, 7]],
      #      #      [[:baz, 2], [:gaz, 5], [:haz, 8]]
      #      #    ]
      #
      #  If any enumerable in other_enums is smaller than self,
      #  fills to <tt>self.size</tt> with +nil+:
      #
      #    a = [:a0, :a1, :a2, :a3]
      #    b = [:b0, :b1, :b2]
      #    c = [:c0, :c1]
      #    d = a.zip(b, c)
      #    d # => [[:a0, :b0, :c0], [:a1, :b1, :c1], [:a2, :b2, nil], [:a3, nil, nil]]
      #
      #  If any enumerable in other_enums is larger than self,
      #  its trailing elements are ignored:
      #
      #    a = [:a0, :a1, :a2, :a3]
      #    b = [:b0, :b1, :b2, :b3, :b4]
      #    c = [:c0, :c1, :c2, :c3, :c4, :c5]
      #    d = a.zip(b, c)
      #    d # => [[:a0, :b0, :c0], [:a1, :b1, :c1], [:a2, :b2, :c2], [:a3, :b3, :c3]]
      #
      #  When a block is given, calls the block with each of the sub-arrays
      #  (formed as above); returns nil:
      #
      #    a = [:a0, :a1, :a2, :a3]
      #    b = [:b0, :b1, :b2, :b3]
      #    c = [:c0, :c1, :c2, :c3]
      #    a.zip(b, c) {|sub_array| p sub_array} # => nil
      #
      #  Output:
      #
      #    [:a0, :b0, :c0]
      #    [:a1, :b1, :c1]
      #    [:a2, :b2, :c2]
      #    [:a3, :b3, :c3]
      def zip
      end
    end
  end
end
