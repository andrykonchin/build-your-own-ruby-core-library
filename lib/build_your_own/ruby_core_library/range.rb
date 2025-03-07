module BuildYourOwn
  module RubyCoreLibrary
    # Documentation from the Ruby Project
    class Range
      include ::Enumerable

      UNDEFINED = Object.new
      private_constant :UNDEFINED

      Pair = Data.define(:left, :right)
      private_constant :Pair

      #  call-seq:
      #    %(n) {|element| ... } -> self
      #    %(n)                  -> enumerator or arithmetic_sequence
      #
      #  Same as #step (but doesn't provide default value for +n+).
      #  The method is convenient for experssive producing of Enumerator::ArithmeticSequence.
      #
      #    array = [0, 1, 2, 3, 4, 5, 6]
      #
      #    # slice each second element:
      #    seq = (0..) % 2 #=> ((0..).%(2))
      #    array[seq] #=> [0, 2, 4, 6]
      #    # or just
      #    array[(0..) % 2] #=> [0, 2, 4, 6]
      #
      #  Note that due to operator precedence in Ruby, parentheses are mandatory around range
      #  in this case:
      #
      #      (0..7) % 2 #=> ((0..7).%(2)) -- as expected
      #      0..7 % 2 #=> 0..1 -- parsed as 0..(7 % 2)
      def %(s, &)
        step(s, &)
      end

      #  call-seq:
      #    self == other -> true or false
      #
      #  Returns +true+ if and only if:
      #
      #  - +other+ is a range.
      #  - <tt>other.begin == self.begin</tt>.
      #  - <tt>other.end == self.end</tt>.
      #  - <tt>other.exclude_end? == self.exclude_end?</tt>.
      #
      #  Otherwise returns +false+.
      #
      #    r = (1..5)
      #    r == (1..5)                # => true
      #    r = Range.new(1, 5)
      #    r == 'foo'                 # => false
      #    r == (2..5)                # => false
      #    r == (1..4)                # => false
      #    r == (1...5)               # => false
      #    r == Range.new(1, 5, true) # => false
      #
      #  Note that even with the same argument, the return values of #== and #eql? can differ:
      #
      #    (1..2) == (1..2.0)   # => true
      #    (1..2).eql? (1..2.0) # => false
      #
      #  Related: Range#eql?.
      def ==(other)
        return false unless other.is_a?(Range)

        @begin == other.begin && @end == other.end && @exclude_end == other.exclude_end?
      end

      #  call-seq:
      #     self === object ->  true or false
      #
      #  Returns +true+ if +object+ is between <tt>self.begin</tt> and <tt>self.end</tt>.
      #  +false+ otherwise:
      #
      #    (1..4) === 2       # => true
      #    (1..4) === 5       # => false
      #    (1..4) === 'a'     # => false
      #    (1..4) === 4       # => true
      #    (1...4) === 4      # => false
      #    ('a'..'d') === 'c' # => true
      #    ('a'..'d') === 'e' # => false
      def ===(object)
        unless @begin.nil?
          determinator = @begin <=> object
          return false if determinator.nil? || determinator > 0 # begin > object
        end

        unless @end.nil?
          determinator = object <=> @end
          return false if determinator.nil?
          return false if @exclude_end && determinator >= 0 # object >= end
          return false if !@exclude_end && determinator > 0 # object > end
        end

        true
      end

      #  call-seq:
      #    self.begin -> object
      #
      #  Returns the object that defines the beginning of +self+.
      #
      #    (1..4).begin # => 1
      #    (..2).begin  # => nil
      #
      #  Related: Range#first, Range#end.
      def begin # rubocop:disable Style/TrivialAccessors
        @begin
      end

      #  call-seq:
      #     bsearch {|obj| block }  -> value
      #
      #  Returns an element from +self+ selected by a binary search.
      #
      #  There are two search modes:
      #
      #  Find-minimum mode:: method +bsearch+ returns the first element for which
      #                      the block returns +true+;
      #                      the block must return +true+ or +false+.
      #  Find-any mode:: method +bsearch+ some element, if any, for which
      #                  the block returns zero.
      #                  the block must return a numeric value.
      #
      #  The block should not mix the modes by sometimes returning +true+ or +false+
      #  and other times returning a numeric value, but this is not checked.
      #
      #  <b>Find-Minimum Mode</b>
      #
      #  In find-minimum mode, the block must return +true+ or +false+.
      #  The further requirement (though not checked) is that
      #  there are no indexes +i+ and +j+ such that:
      #
      #  - <tt>0 <= i < j <= self.size</tt>.
      #  - The block returns +true+ for <tt>self[i]</tt> and +false+ for <tt>self[j]</tt>.
      #
      #  Less formally: the block is such that all +false+-evaluating elements
      #  precede all +true+-evaluating elements.
      #
      #  In find-minimum mode, method +bsearch+ returns the first element
      #  for which the block returns +true+.
      #
      #  Examples:
      #
      #    a = [0, 4, 7, 10, 12]
      #    a.bsearch {|x| x >= 4 } # => 4
      #    a.bsearch {|x| x >= 6 } # => 7
      #    a.bsearch {|x| x >= -1 } # => 0
      #    a.bsearch {|x| x >= 100 } # => nil
      #
      #    r = (0...a.size)
      #    r.bsearch {|i| a[i] >= 4 } #=> 1
      #    r.bsearch {|i| a[i] >= 6 } #=> 2
      #    r.bsearch {|i| a[i] >= 8 } #=> 3
      #    r.bsearch {|i| a[i] >= 100 } #=> nil
      #    r = (0.0...Float::INFINITY)
      #    r.bsearch {|x| Math.log(x) >= 0 } #=> 1.0
      #
      #  These blocks make sense in find-minimum mode:
      #
      #    a = [0, 4, 7, 10, 12]
      #    a.map {|x| x >= 4 } # => [false, true, true, true, true]
      #    a.map {|x| x >= 6 } # => [false, false, true, true, true]
      #    a.map {|x| x >= -1 } # => [true, true, true, true, true]
      #    a.map {|x| x >= 100 } # => [false, false, false, false, false]
      #
      #  This would not make sense:
      #
      #    a.map {|x| x == 7 } # => [false, false, true, false, false]
      #
      #  <b>Find-Any Mode</b>
      #
      #  In find-any mode, the block must return a numeric value.
      #  The further requirement (though not checked) is that
      #  there are no indexes +i+ and +j+ such that:
      #
      #  - <tt>0 <= i < j <= self.size</tt>.
      #  - The block returns a negative value for <tt>self[i]</tt>
      #    and a positive value for <tt>self[j]</tt>.
      #  - The block returns a negative value for <tt>self[i]</tt> and zero <tt>self[j]</tt>.
      #  - The block returns zero for <tt>self[i]</tt> and a positive value for <tt>self[j]</tt>.
      #
      #  Less formally: the block is such that:
      #
      #  - All positive-evaluating elements precede all zero-evaluating elements.
      #  - All positive-evaluating elements precede all negative-evaluating elements.
      #  - All zero-evaluating elements precede all negative-evaluating elements.
      #
      #  In find-any mode, method +bsearch+ returns some element
      #  for which the block returns zero, or +nil+ if no such element is found.
      #
      #  Examples:
      #
      #    a = [0, 4, 7, 10, 12]
      #    a.bsearch {|element| 7 <=> element } # => 7
      #    a.bsearch {|element| -1 <=> element } # => nil
      #    a.bsearch {|element| 5 <=> element } # => nil
      #    a.bsearch {|element| 15 <=> element } # => nil
      #
      #    a = [0, 100, 100, 100, 200]
      #    r = (0..4)
      #    r.bsearch {|i| 100 - a[i] } #=> 1, 2 or 3
      #    r.bsearch {|i| 300 - a[i] } #=> nil
      #    r.bsearch {|i|  50 - a[i] } #=> nil
      #
      #  These blocks make sense in find-any mode:
      #
      #    a = [0, 4, 7, 10, 12]
      #    a.map {|element| 7 <=> element } # => [1, 1, 0, -1, -1]
      #    a.map {|element| -1 <=> element } # => [-1, -1, -1, -1, -1]
      #    a.map {|element| 5 <=> element } # => [1, 1, -1, -1, -1]
      #    a.map {|element| 15 <=> element } # => [1, 1, 1, 1, 1]
      #
      #  This would not make sense:
      #
      #    a.map {|element| element <=> 7 } # => [-1, -1, 0, 1, 1]
      def bsearch
        # only Integer/Float ranges are supported
        if @begin && (!@begin.is_a?(Integer) && !@begin.is_a?(Float))
          raise TypeError, "can't do binary search for #{@begin.class}"
        end
        if @end && (!@end.is_a?(Integer) && !@end.is_a?(Float))
          raise TypeError, "can't do binary search for #{@end.class}"
        end

        if @begin.nil? && @end.nil?
          raise TypeError, "can't do binary search for #{nil.class}"
        end

        # backward or empty range
        if @begin && @end && (@begin > @end || (@begin == @end && @exclude_end))
          return nil
        end

        return to_enum(:bsearch) unless block_given?

        from = @begin
        to = @end

        # support Infinity boundaries
        # use Integer values (that's #to_i method) to represend Infinity to not loose precision
        if from == -Float::INFINITY
          from = to.is_a?(Integer) ? nil : -Float::MAX.to_i
        end
        if to == Float::INFINITY
          to = from.is_a?(Integer) ? nil : Float::MAX.to_i
        end

        # find left/right boundary for beginingless/endless ranges
        if from.nil?
          from = to

          diff = 1
          while (br = yield(from); br == true || (br.is_a?(Numeric) && br < 0)) # rubocop:disable Lint/AssignmentInCondition
            from -= diff
            diff *= 2
          end
        end
        if to.nil?
          to = from

          diff = 1
          while (br = yield(to); (br == false || br.nil?) || (br.is_a?(Numeric) && br > 0)) # rubocop:disable Lint/AssignmentInCondition
            to += diff
            diff *= 2
          end
        end

        while from + 1 < to
          middle = (from + to) / 2

          block_result = yield(middle)
          unless block_result == true || block_result == false || block_result.nil? || block_result.is_a?(Numeric)
            raise TypeError, "wrong argument type #{block_result.class} (must be numeric, true, false or nil)"
          end

          if block_result == true || (block_result.is_a?(Numeric) && block_result < 0)
            to = middle
          else
            from = middle
          end
        end

        br = yield(from)
        unless br == true || br == false || br.nil? || br.is_a?(Numeric)
          raise TypeError, "wrong argument type #{br.class} (must be numeric, true, false or nil)"
        end
        if (br == true || (br.is_a?(Numeric) && br == 0)) && !(@end && from == @end && @exclude_end)
          return from
        end

        br = yield(to)
        unless br == true || br == false || br.nil? || br.is_a?(Numeric)
          raise TypeError, "wrong argument type #{br.class} (must be numeric, true, false or nil)"
        end
        if (br == true || (br.is_a?(Numeric) && br == 0)) && !(@end && to == @end && @exclude_end)
          return to
        end

        nil
      end

      #  call-seq:
      #    count -> integer
      #    count(object) -> integer
      #    count {|element| ... } -> integer
      #
      #  Returns the count of elements, based on an argument or block criterion, if given.
      #
      #  With no argument and no block given, returns the number of elements:
      #
      #    (1..4).count      # => 4
      #    (1...4).count     # => 3
      #    ('a'..'d').count  # => 4
      #    ('a'...'d').count # => 3
      #    (1..).count       # => Infinity
      #    (..4).count       # => Infinity
      #
      #  With argument +object+, returns the number of +object+ found in +self+,
      #  which will usually be zero or one:
      #
      #    (1..4).count(2)   # => 1
      #    (1..4).count(5)   # => 0
      #    (1..4).count('a')  # => 0
      #
      #  With a block given, calls the block with each element;
      #  returns the number of elements for which the block returns a truthy value:
      #
      #    (1..4).count {|element| element < 3 } # => 2
      #
      #  Related: Range#size.
      def count(object = UNDEFINED, &)
        if (@begin.nil? || @end.nil?) && object == UNDEFINED && !block_given?
          return Float::INFINITY
        end

        if object != UNDEFINED
          super
        elsif block_given?
          super(&)
        else
          super()
        end
      end

      #  call-seq:
      #    cover?(object) -> true or false
      #    cover?(range) -> true or false
      #
      #  Returns +true+ if the given argument is within +self+, +false+ otherwise.
      #
      #  With non-range argument +object+, evaluates with <tt><=</tt> and <tt><</tt>.
      #
      #  For range +self+ with included end value (<tt>#exclude_end? == false</tt>),
      #  evaluates thus:
      #
      #    self.begin <= object <= self.end
      #
      #  Examples:
      #
      #    r = (1..4)
      #    r.cover?(1)     # => true
      #    r.cover?(4)     # => true
      #    r.cover?(0)     # => false
      #    r.cover?(5)     # => false
      #    r.cover?('foo') # => false
      #
      #    r = ('a'..'d')
      #    r.cover?('a')     # => true
      #    r.cover?('d')     # => true
      #    r.cover?(' ')     # => false
      #    r.cover?('e')     # => false
      #    r.cover?(0)       # => false
      #
      #  For range +r+ with excluded end value (<tt>#exclude_end? == true</tt>),
      #  evaluates thus:
      #
      #    r.begin <= object < r.end
      #
      #  Examples:
      #
      #    r = (1...4)
      #    r.cover?(1)     # => true
      #    r.cover?(3)     # => true
      #    r.cover?(0)     # => false
      #    r.cover?(4)     # => false
      #    r.cover?('foo') # => false
      #
      #    r = ('a'...'d')
      #    r.cover?('a')     # => true
      #    r.cover?('c')     # => true
      #    r.cover?(' ')     # => false
      #    r.cover?('d')     # => false
      #    r.cover?(0)       # => false
      #
      #  With range argument +range+, compares the first and last
      #  elements of +self+ and +range+:
      #
      #    r = (1..4)
      #    r.cover?(1..4)     # => true
      #    r.cover?(0..4)     # => false
      #    r.cover?(1..5)     # => false
      #    r.cover?('a'..'d') # => false
      #
      #    r = (1...4)
      #    r.cover?(1..3)     # => true
      #    r.cover?(1..4)     # => false
      #
      #  If begin and end are numeric, #cover? behaves like #include?
      #
      #    (1..3).cover?(1.5) # => true
      #    (1..3).include?(1.5) # => true
      #
      #  But when not numeric, the two methods may differ:
      #
      #    ('a'..'d').cover?('cc')   # => true
      #    ('a'..'d').include?('cc') # => false
      #
      #  Returns +false+ if either:
      #
      #  - The begin value of +self+ is larger than its end value.
      #  - An internal call to <tt>#<=></tt> returns +nil+;
      #    that is, the operands are not comparable.
      #
      #  Beginless ranges cover all values of the same type before the end,
      #  excluding the end for exclusive ranges. Beginless ranges cover
      #  ranges that end before the end of the beginless range, or at the
      #  end of the beginless range for inclusive ranges.
      #
      #     (..2).cover?(1)     # => true
      #     (..2).cover?(2)     # => true
      #     (..2).cover?(3)     # => false
      #     (...2).cover?(2)    # => false
      #     (..2).cover?("2")   # => false
      #     (..2).cover?(..2)   # => true
      #     (..2).cover?(...2)  # => true
      #     (..2).cover?(.."2") # => false
      #     (...2).cover?(..2)  # => false
      #
      #  Endless ranges cover all values of the same type after the
      #  beginning. Endless exclusive ranges do not cover endless
      #  inclusive ranges.
      #
      #     (2..).cover?(1)     # => false
      #     (2..).cover?(3)     # => true
      #     (2...).cover?(3)    # => true
      #     (2..).cover?(2)     # => true
      #     (2..).cover?("2")   # => false
      #     (2..).cover?(2..)   # => true
      #     (2..).cover?(2...)  # => true
      #     (2..).cover?("2"..) # => false
      #     (2...).cover?(2..)  # => false
      #     (2...).cover?(3...) # => true
      #     (2...).cover?(3..)  # => false
      #     (3..).cover?(2..)   # => false
      #
      #  Ranges that are both beginless and endless cover all values and
      #  ranges, and return true for all arguments, with the exception that
      #  beginless and endless exclusive ranges do not cover endless
      #  inclusive ranges.
      #
      #     (nil...).cover?(Object.new) # => true
      #     (nil...).cover?(nil...)     # => true
      #     (nil..).cover?(nil...)      # => true
      #     (nil...).cover?(nil..)      # => false
      #     (nil...).cover?(1..)        # => false
      #
      #  Related: Range#include?.
      def cover?(object)
        if object.is_a?(Range)
          # object is a backward range
          if object.begin && object.end && (object.begin <=> object.end) > 0
            return false
          end

          # object is an empty range
          if object.begin && object.end && (object.begin <=> object.end) == 0 && object.exclude_end?
            return false
          end

          # self is nil..nil (or nil...nil)
          if @begin.nil? && @end.nil?
            return !object.end.nil? || !@exclude_end || object.exclude_end?
          end

          # both ranges are finite
          #   begin <= object.begin && end >= object.end
          # self is beginingless
          #   end >= object.end
          if @end && object.end
            if @begin && object.begin
              determinator_begin = @begin <=> object.begin
              return false if determinator_begin.nil?
              return false if determinator_begin > 0
            end

            if @begin && !object.begin
              return false
            end

            determinator = @end <=> object.end
            return false if determinator.nil?
            return true if determinator > 0
            if determinator == 0
              return !@exclude_end || object.exclude_end?
            end
            return false unless object.exclude_end?

            determinator = @end <=> object.max
            return false if determinator.nil?

            return determinator >= 0 # end >= object.max
          end

          # self is endless
          if @end.nil? && object.begin
            # begin <= object.begin
            determinator = @begin <=> object.begin
            return false if determinator.nil?

            return determinator <= 0 && (!object.end.nil? || !@exclude_end || object.exclude_end?)
          end

          false
        else
          if @begin.nil? && @end.nil?
            return true
          end

          if @begin
            determinator = @begin <=> object
            return false if determinator.nil?
            return false if determinator > 0 # begin > object
          end

          if @end
            determinator = object <=> @end
            return false if determinator.nil?

            if @exclude_end
              return false if determinator >= 0 # object >= end
            else
              return false if determinator > 0 # object > end
            end
          end

          true
        end
      end

      #  call-seq:
      #    each {|element| ... } -> self
      #    each                  -> an_enumerator
      #
      #  With a block given, passes each element of +self+ to the block:
      #
      #    a = []
      #    (1..4).each {|element| a.push(element) } # => 1..4
      #    a # => [1, 2, 3, 4]
      #
      #  Raises an exception unless <tt>self.first.respond_to?(:succ)</tt>.
      #
      #  With no block given, returns an enumerator.
      def each
        return to_enum(:each) { size } unless block_given?

        unless @begin.respond_to?(:succ)
          raise TypeError, "can't iterate from #{@begin.class}"
        end

        if @begin.is_a?(String) || @begin.is_a?(Symbol)
          # if backward or empty
          if @end && (@begin > @end || (@exclude_end && @begin == @end))
            return self
          end

          e = @begin

          if @end.nil?
            loop do
              yield e
              e = e.succ
            end
          elsif @exclude_end
            while compare(e, @end) != 0 # that's e != @end
              yield e
              e = e.succ
            end
          else
            after_end = @end.succ
            while compare(e, after_end) != 0 # that's e != end.succ
              yield e
              e = e.succ
            end
          end

          return self
        end

        e = @begin

        if @end.nil?
          loop do
            yield e
            e = e.succ
          end
        elsif @exclude_end
          while compare(e, @end) < 0 # that's e < @end
            yield e
            e = e.succ
          end
        else
          while compare(e, @end) <= 0 # that's e <= @end
            yield e
            e = e.succ
          end
        end

        self
      end

      #  call-seq:
      #    self.end -> object
      #
      #  Returns the object that defines the end of +self+.
      #
      #    (1..4).end  # => 4
      #    (1...4).end # => 4
      #    (1..).end   # => nil
      #
      #  Related: Range#begin, Range#last.
      def end # rubocop:disable Style/TrivialAccessors
        @end
      end

      #  call-seq:
      #    eql?(other) -> true or false
      #
      #  Returns +true+ if and only if:
      #
      #  - +other+ is a range.
      #  - <tt>other.begin.eql?(self.begin)</tt>.
      #  - <tt>other.end.eql?(self.end)</tt>.
      #  - <tt>other.exclude_end? == self.exclude_end?</tt>.
      #
      #  Otherwise returns +false+.
      #
      #    r = (1..5)
      #    r.eql?(1..5)                  # => true
      #    r = Range.new(1, 5)
      #    r.eql?('foo')                 # => false
      #    r.eql?(2..5)                  # => false
      #    r.eql?(1..4)                  # => false
      #    r.eql?(1...5)                 # => false
      #    r.eql?(Range.new(1, 5, true)) # => false
      #
      #  Note that even with the same argument, the return values of #== and #eql? can differ:
      #
      #    (1..2) == (1..2.0)   # => true
      #    (1..2).eql? (1..2.0) # => false
      #
      #  Related: Range#==.
      def eql?(other)
        return false unless other.is_a?(Range)

        @begin.eql?(other.begin) && @end.eql?(other.end) && @exclude_end == other.exclude_end?
      end

      #  call-seq:
      #     exclude_end? -> true or false
      #
      #  Returns +true+ if +self+ excludes its end value; +false+ otherwise:
      #
      #    Range.new(2, 5).exclude_end?       # => false
      #    Range.new(2, 5, true).exclude_end? # => true
      #    (2..5).exclude_end?                # => false
      #    (2...5).exclude_end?               # => true
      def exclude_end?
        @exclude_end
      end

      #  call-seq:
      #    first -> object
      #    first(n) -> array
      #
      #  With no argument, returns the first element of +self+, if it exists:
      #
      #    (1..4).first     # => 1
      #    ('a'..'d').first # => "a"
      #
      #  With non-negative integer argument +n+ given,
      #  returns the first +n+ elements in an array:
      #
      #    (1..10).first(3) # => [1, 2, 3]
      #    (1..10).first(0) # => []
      #    (1..4).first(50) # => [1, 2, 3, 4]
      #
      #  Raises an exception if there is no first element:
      #
      #    (..4).first # Raises RangeError
      def first(n = UNDEFINED)
        if @begin.nil?
          raise RangeError, 'cannot get the first element of beginless range'
        end

        if n == UNDEFINED
          @begin
        else
          take(n)
        end
      end

      # call-seq:
      #   hash -> integer
      #
      # Returns the integer hash value for +self+.
      # Two range objects +r0+ and +r1+ have the same hash value
      # if and only if <tt>r0.eql?(r1)</tt>.
      #
      # Related: Range#eql?, Object#hash.
      def hash
        [@exclude_end, @begin, @end].hash
      end

      #  call-seq:
      #    include?(object) -> true or false
      #
      #  Returns +true+ if +object+ is an element of +self+, +false+ otherwise:
      #
      #    (1..4).include?(2)        # => true
      #    (1..4).include?(5)        # => false
      #    (1..4).include?(4)        # => true
      #    (1...4).include?(4)       # => false
      #    ('a'..'d').include?('b')  # => true
      #    ('a'..'d').include?('e')  # => false
      #    ('a'..'d').include?('B')  # => false
      #    ('a'..'d').include?('d')  # => true
      #    ('a'...'d').include?('d') # => false
      #
      #  If begin and end are numeric, #include? behaves like #cover?
      #
      #    (1..3).include?(1.5) # => true
      #    (1..3).cover?(1.5) # => true
      #
      #  But when not numeric, the two methods may differ:
      #
      #    ('a'..'d').include?('cc') # => false
      #    ('a'..'d').cover?('cc')   # => true
      #
      #  Related: Range#cover?.
      def include?(object)
        if (@begin.is_a?(Numeric) || @end.is_a?(Numeric)) || (@begin.is_a?(Time) || @end.is_a?(Time))
          if @begin
            determinator = @begin <=> object
            return false if determinator.nil? || determinator > 0 # begin > object
          end

          if @end
            determinator = object <=> @end
            greater_determinator = @exclude_end ? 0 : 1
            return false if determinator.nil? || determinator >= greater_determinator # object > end
          end

          return true
        end

        if @begin.nil? || @end.nil?
          raise TypeError, 'cannot determine inclusion in beginless/endless ranges'
        end

        if @begin.is_a?(String) || @end.is_a?(String)
          object = to_string(object)
          return false if object.nil?
        end

        super
      end

      #  call-seq:
      #    Range.new(begin, end, exclude_end = false) -> new_range
      #
      #  Returns a new range based on the given objects +begin+ and +end+.
      #  Optional argument +exclude_end+ determines whether object +end+
      #  is included as the last object in the range:
      #
      #    Range.new(2, 5).to_a            # => [2, 3, 4, 5]
      #    Range.new(2, 5, true).to_a      # => [2, 3, 4]
      #    Range.new('a', 'd').to_a        # => ["a", "b", "c", "d"]
      #    Range.new('a', 'd', true).to_a  # => ["a", "b", "c"]
      def initialize(from, to, exclude_end = false) # rubocop:disable Style/OptionalBooleanParameter
        already_initialized = !@exclude_end.nil?

        @begin = from
        @end = to
        @exclude_end = !!exclude_end # rubocop:disable Style/DoubleNegation

        if already_initialized
          raise NameError, "'initialize' called twice"
        end

        unless from.nil? || to.nil? || (from.respond_to?(:<=>) && from <=> to)
          raise ArgumentError, 'bad value for range'
        end

        if instance_of?(Range)
          freeze
        end
      end

      # call-seq:
      #   inspect -> string
      #
      # Returns a string representation of +self+,
      # including <tt>begin.inspect</tt> and <tt>end.inspect</tt>:
      #
      #   (1..4).inspect  # => "1..4"
      #   (1...4).inspect # => "1...4"
      #   (1..).inspect   # => "1.."
      #   (..4).inspect   # => "..4"
      #
      # Note that returns from #to_s and #inspect may differ:
      #
      #   ('a'..'d').to_s    # => "a..d"
      #   ('a'..'d').inspect # => "\"a\"..\"d\""
      #
      # Related: Range#to_s.
      def inspect
        if @begin.nil? && @end.nil?
          suffix = @exclude_end ? '...' : '..'
          return "nil#{suffix}nil"
        end

        begin_as_string = @begin ? @begin.inspect : ''
        end_as_string = @end ? @end.inspect : ''
        suffix = @exclude_end ? '...' : '..'

        begin_as_string + suffix + end_as_string
      end

      #  call-seq:
      #    last -> object
      #    last(n) -> array
      #
      #  With no argument, returns the last element of +self+, if it exists:
      #
      #    (1..4).last     # => 4
      #    ('a'..'d').last # => "d"
      #
      #  Note that +last+ with no argument returns the end element of +self+
      #  even if #exclude_end? is +true+:
      #
      #    (1...4).last     # => 4
      #    ('a'...'d').last # => "d"
      #
      #  With non-negative integer argument +n+ given,
      #  returns the last +n+ elements in an array:
      #
      #    (1..10).last(3) # => [8, 9, 10]
      #    (1..10).last(0) # => []
      #    (1..4).last(50) # => [1, 2, 3, 4]
      #
      #  Note that +last+ with argument does not return the end element of +self+
      #  if #exclude_end? it +true+:
      #
      #    (1...4).last(3)     # => [1, 2, 3]
      #    ('a'...'d').last(3) # => ["a", "b", "c"]
      #
      #  Raises an exception if there is no last element:
      #
      #    (1..).last # Raises RangeError
      def last(n = UNDEFINED)
        if @end.nil?
          raise RangeError, 'cannot get the last element of endless range'
        end

        if n == UNDEFINED
          @end
        else
          to_a.last(n)
        end
      end

      #  call-seq:
      #    max -> object
      #    max(n) -> array
      #    max {|a, b| ... } -> object
      #    max(n) {|a, b| ... } -> array
      #
      #  Returns the maximum value in +self+,
      #  using method <tt>#<=></tt> or a given block for comparison.
      #
      #  With no argument and no block given,
      #  returns the maximum-valued element of +self+.
      #
      #    (1..4).max     # => 4
      #    ('a'..'d').max # => "d"
      #    (-4..-1).max   # => -1
      #
      #  With non-negative integer argument +n+ given, and no block given,
      #  returns the +n+ maximum-valued elements of +self+ in an array:
      #
      #    (1..4).max(2)     # => [4, 3]
      #    ('a'..'d').max(2) # => ["d", "c"]
      #    (-4..-1).max(2)   # => [-1, -2]
      #    (1..4).max(50)    # => [4, 3, 2, 1]
      #
      #  If a block is given, it is called:
      #
      #  - First, with the first two element of +self+.
      #  - Then, sequentially, with the so-far maximum value and the next element of +self+.
      #
      #  To illustrate:
      #
      #    (1..4).max {|a, b| p [a, b]; a <=> b } # => 4
      #
      #  Output:
      #
      #    [2, 1]
      #    [3, 2]
      #    [4, 3]
      #
      #  With no argument and a block given,
      #  returns the return value of the last call to the block:
      #
      #    (1..4).max {|a, b| -(a <=> b) } # => 1
      #
      #  With non-negative integer argument +n+ given, and a block given,
      #  returns the return values of the last +n+ calls to the block in an array:
      #
      #    (1..4).max(2) {|a, b| -(a <=> b) }  # => [1, 2]
      #    (1..4).max(50) {|a, b| -(a <=> b) } # => [1, 2, 3, 4]
      #
      #  Returns an empty array if +n+ is zero:
      #
      #    (1..4).max(0)                      # => []
      #    (1..4).max(0) {|a, b| -(a <=> b) } # => []
      #
      #  Returns +nil+ or an empty array if:
      #
      #  - The begin value of the range is larger than the end value:
      #
      #      (4..1).max                         # => nil
      #      (4..1).max(2)                      # => []
      #      (4..1).max {|a, b| -(a <=> b) }    # => nil
      #      (4..1).max(2) {|a, b| -(a <=> b) } # => []
      #
      #  - The begin value of an exclusive range is equal to the end value:
      #
      #      (1...1).max                          # => nil
      #      (1...1).max(2)                       # => []
      #      (1...1).max  {|a, b| -(a <=> b) }    # => nil
      #      (1...1).max(2)  {|a, b| -(a <=> b) } # => []
      #
      #  Raises an exception if either:
      #
      #  - +self+ is a endless range: <tt>(1..)</tt>.
      #  - A block is given and +self+ is a beginless range.
      #
      #  Related: Range#min, Range#minmax.
      def max(n = UNDEFINED, &)
        if @end.nil?
          raise RangeError, 'cannot get the maximum of endless range'
        end

        # a complex case - it's needed to iterate a range
        if n != UNDEFINED || block_given? || (@exclude_end && !@end.is_a?(Numeric))
          if @begin.nil?
            raise RangeError, 'cannot get the maximum of beginless range with custom comparison method'
          end

          if n == UNDEFINED
            return super(&)
          else
            return super(n)
          end
        end

        # a simple case

        # backward or empty range
        if @exclude_end
          return nil if !@begin.nil? && (@begin <=> @end) >= 0 # begin >= end
        else
          return nil if !@begin.nil? && (@begin <=> @end) > 0 # begin > end
        end

        if @exclude_end && !@end.is_a?(Integer)
          raise TypeError, 'cannot exclude non Integer end value'
        end

        if @exclude_end && !@begin.is_a?(Integer)
          raise TypeError, 'cannot exclude end value with non Integer begin value'
        end

        if @exclude_end
          # expect @end to be Integer
          @end - 1
        else
          @end
        end
      end

      #  call-seq:
      #    min -> object
      #    min(n) -> array
      #    min {|a, b| ... } -> object
      #    min(n) {|a, b| ... } -> array
      #
      #  Returns the minimum value in +self+,
      #  using method <tt>#<=></tt> or a given block for comparison.
      #
      #  With no argument and no block given,
      #  returns the minimum-valued element of +self+.
      #
      #    (1..4).min     # => 1
      #    ('a'..'d').min # => "a"
      #    (-4..-1).min   # => -4
      #
      #  With non-negative integer argument +n+ given, and no block given,
      #  returns the +n+ minimum-valued elements of +self+ in an array:
      #
      #    (1..4).min(2)     # => [1, 2]
      #    ('a'..'d').min(2) # => ["a", "b"]
      #    (-4..-1).min(2)   # => [-4, -3]
      #    (1..4).min(50)    # => [1, 2, 3, 4]
      #
      #  If a block is given, it is called:
      #
      #  - First, with the first two element of +self+.
      #  - Then, sequentially, with the so-far minimum value and the next element of +self+.
      #
      #  To illustrate:
      #
      #    (1..4).min {|a, b| p [a, b]; a <=> b } # => 1
      #
      #  Output:
      #
      #    [2, 1]
      #    [3, 1]
      #    [4, 1]
      #
      #  With no argument and a block given,
      #  returns the return value of the last call to the block:
      #
      #    (1..4).min {|a, b| -(a <=> b) } # => 4
      #
      #  With non-negative integer argument +n+ given, and a block given,
      #  returns the return values of the last +n+ calls to the block in an array:
      #
      #    (1..4).min(2) {|a, b| -(a <=> b) }  # => [4, 3]
      #    (1..4).min(50) {|a, b| -(a <=> b) } # => [4, 3, 2, 1]
      #
      #  Returns an empty array if +n+ is zero:
      #
      #    (1..4).min(0)                      # => []
      #    (1..4).min(0) {|a, b| -(a <=> b) } # => []
      #
      #  Returns +nil+ or an empty array if:
      #
      #  - The begin value of the range is larger than the end value:
      #
      #      (4..1).min                         # => nil
      #      (4..1).min(2)                      # => []
      #      (4..1).min {|a, b| -(a <=> b) }    # => nil
      #      (4..1).min(2) {|a, b| -(a <=> b) } # => []
      #
      #  - The begin value of an exclusive range is equal to the end value:
      #
      #      (1...1).min                          # => nil
      #      (1...1).min(2)                       # => []
      #      (1...1).min  {|a, b| -(a <=> b) }    # => nil
      #      (1...1).min(2)  {|a, b| -(a <=> b) } # => []
      #
      #  Raises an exception if either:
      #
      #  - +self+ is a beginless range: <tt>(..4)</tt>.
      #  - A block is given and +self+ is an endless range.
      #
      #  Related: Range#max, Range#minmax.
      def min(n = UNDEFINED, &)
        if @begin.nil?
          raise RangeError, 'cannot get the minimum of beginless range'
        end

        if @end.nil? && block_given?
          raise RangeError, 'cannot get the minimum of endless range with custom comparison method'
        end

        if n != UNDEFINED || block_given?
          # a complex case
          if n == UNDEFINED
            super(&)
          else
            super
          end
        else
          # a simple one
          if @exclude_end
            return nil if !@end.nil? && (@begin <=> @end) >= 0
          else
            return nil if !@end.nil? && (@begin <=> @end) > 0
          end

          @begin
        end
      end

      #  call-seq:
      #    minmax -> [object, object]
      #    minmax {|a, b| ... } -> [object, object]
      #
      #  Returns a 2-element array containing the minimum and maximum value in +self+,
      #  either according to comparison method <tt>#<=></tt> or a given block.
      #
      #  With no block given, returns the minimum and maximum values,
      #  using <tt>#<=></tt> for comparison:
      #
      #    (1..4).minmax     # => [1, 4]
      #    (1...4).minmax    # => [1, 3]
      #    ('a'..'d').minmax # => ["a", "d"]
      #    (-4..-1).minmax   # => [-4, -1]
      #
      #  With a block given, the block must return an integer:
      #
      #  - Negative if +a+ is smaller than +b+.
      #  - Zero if +a+ and +b+ are equal.
      #  - Positive if +a+ is larger than +b+.
      #
      #  The block is called <tt>self.size</tt> times to compare elements;
      #  returns a 2-element Array containing the minimum and maximum values from +self+,
      #  per the block:
      #
      #    (1..4).minmax {|a, b| -(a <=> b) } # => [4, 1]
      #
      #  Returns <tt>[nil, nil]</tt> if:
      #
      #  - The begin value of the range is larger than the end value:
      #
      #      (4..1).minmax                      # => [nil, nil]
      #      (4..1).minmax {|a, b| -(a <=> b) } # => [nil, nil]
      #
      #  - The begin value of an exclusive range is equal to the end value:
      #
      #      (1...1).minmax                          # => [nil, nil]
      #      (1...1).minmax  {|a, b| -(a <=> b) }    # => [nil, nil]
      #
      #  Raises an exception if +self+ is a beginless or an endless range.
      #
      #  Related: Range#min, Range#max.
      def minmax
        unless block_given?
          if @begin.nil?
            raise RangeError, 'cannot get the minimum of beginless range'
          end

          if @end.nil?
            raise RangeError, 'cannot get the maximum of endless range'
          end
        end

        super
      end

      #  call-seq:
      #    overlap?(range) -> true or false
      #
      #  Returns +true+ if +range+ overlaps with +self+, +false+ otherwise:
      #
      #    (0..2).overlap?(1..3) #=> true
      #    (0..2).overlap?(3..4) #=> false
      #    (0..).overlap?(..0)   #=> true
      #
      #  With non-range argument, raises TypeError.
      #
      #    (1..3).overlap?(1)         # TypeError
      #
      #  Returns +false+ if an internal call to <tt>#<=></tt> returns +nil+;
      #  that is, the operands are not comparable.
      #
      #    (1..3).overlap?('a'..'d')  # => false
      #
      #  Returns +false+ if +self+ or +range+ is empty. "Empty range" means
      #  that its begin value is larger than, or equal for an exclusive
      #  range, its end value.
      #
      #    (4..1).overlap?(2..3)      # => false
      #    (4..1).overlap?(..3)       # => false
      #    (4..1).overlap?(2..)       # => false
      #    (2...2).overlap?(1..2)     # => false
      #
      #    (1..4).overlap?(3..2)      # => false
      #    (..4).overlap?(3..2)       # => false
      #    (1..).overlap?(3..2)       # => false
      #    (1..2).overlap?(2...2)     # => false
      #
      #  Returns +false+ if the begin value one of +self+ and +range+ is
      #  larger than, or equal if the other is an exclusive range, the end
      #  value of the other:
      #
      #    (4..5).overlap?(2..3)      # => false
      #    (4..5).overlap?(2...4)     # => false
      #
      #    (1..2).overlap?(3..4)      # => false
      #    (1...3).overlap?(3..4)     # => false
      #
      #  Returns +false+ if the end value one of +self+ and +range+ is
      #  larger than, or equal for an exclusive range, the end value of the
      #  other:
      #
      #    (4..5).overlap?(2..3)      # => false
      #    (4..5).overlap?(2...4)     # => false
      #
      #    (1..2).overlap?(3..4)      # => false
      #    (1...3).overlap?(3..4)     # => false
      #
      #  Note that the method wouldn't make any assumptions about the beginless
      #  range being actually empty, even if its upper bound is the minimum
      #  possible value of its type, so all this would return +true+:
      #
      #     (...-Float::INFINITY).overlap?(...-Float::INFINITY) # => true
      #     (..."").overlap?(..."") # => true
      #     (...[]).overlap?(...[]) # => true
      #
      #  Even if those ranges are effectively empty (no number can be smaller than
      #  <tt>-Float::INFINITY</tt>), they are still considered overlapping
      #  with themselves.
      #
      #  Related: Range#cover?.
      def overlap?(other)
        unless other.is_a?(Range)
          raise TypeError, "wrong argument type #{other.class} (expected Range)"
        end

        # self is backward or empty
        if @begin && @end
          determinator = @begin <=> @end

          if determinator > 0 || (determinator == 0 && @exclude_end)
            return false
          end
        end

        # other is backward or empty
        if other.begin && other.end
          determinator = other.begin <=> other.end

          if determinator > 0 || (determinator == 0 && other.exclude_end?)
            return false
          end
        end

        # beginingless and endless at the same time
        if @begin.nil? && @end.nil?
          return true
        end
        if other.begin.nil? && other.end.nil?
          return true
        end

        # self and other are endless (or beginingless) at the same time
        if @begin.nil? && other.begin.nil?
          return true
        end
        if @end.nil? && other.end.nil?
          return true
        end

        # self is beginingless or endless
        if @begin.nil?
          determinator = @end <=> other.begin
          return false if determinator.nil?

          if @exclude_end
            return determinator > 0 # end > other.begin
          else
            return determinator >= 0 # end >= other.begin
          end
        end
        if @end.nil?
          determinator = @begin <=> other.end
          return false if determinator.nil?

          if other.exclude_end?
            return determinator < 0 # begin < other.end
          else
            return determinator <= 0 # begin <= other.end
          end
        end

        # other is beginingless or endless
        if other.begin.nil?
          determinator = other.end <=> @begin
          return false if determinator.nil?

          if other.exclude_end?
            return determinator > 0 # end > other.begin
          else
            return determinator >= 0 # end >= other.begin
          end
        end
        if other.end.nil?
          determinator = other.begin <=> @end
          return false if determinator.nil?

          if @exclude_end
            return determinator < 0 # begin < other.end
          else
            return determinator <= 0 # begin <= other.end
          end
        end

        # self and other are finit
        determinator_begin = @begin <=> other.end
        return false if determinator_begin.nil?

        determinator_end = @end <=> other.begin
        return false if determinator_end.nil?

        if other.exclude_end?
          return false if determinator_begin >= 0
        else
          return false if determinator_begin > 0
        end

        if @exclude_end
          return false if determinator_end <= 0
        else
          return false if determinator_end < 0
        end

        true
      end

      #  call-seq:
      #    reverse_each {|element| ... } -> self
      #    reverse_each                  -> an_enumerator
      #
      #  With a block given, passes each element of +self+ to the block in reverse order:
      #
      #    a = []
      #    (1..4).reverse_each {|element| a.push(element) } # => 1..4
      #    a # => [4, 3, 2, 1]
      #
      #    a = []
      #    (1...4).reverse_each {|element| a.push(element) } # => 1...4
      #    a # => [3, 2, 1]
      #
      #  With no block given, returns an enumerator.
      def reverse_each
        unless block_given?
          return to_enum(:reverse_each) do
            if @end.nil?
              raise TypeError, "can't iterate from NilClass"
            end

            if @begin.nil?
              if @end.is_a?(Numeric)
                Float::INFINITY
              else
                raise TypeError, "can't iterate from #{@end.class}"
              end
            else
              size
            end
          end
        end

        if @end.nil?
          raise TypeError, "can't iterate from NilClass"
        end

        if @begin.nil? && @end.is_a?(Integer)
          n = @end
          n -= 1 if @exclude_end

          loop do
            yield n
            n -= 1
          end
        end

        super
      end

      #  call-seq:
      #    size -> non_negative_integer or Infinity or nil
      #
      #  Returns the count of elements in +self+
      #  if both begin and end values are numeric;
      #  otherwise, returns +nil+:
      #
      #    (1..4).size      # => 4
      #    (1...4).size     # => 3
      #    (1..).size       # => Infinity
      #    ('a'..'z').size  # => nil
      #
      #  If +self+ is not iterable, raises an exception:
      #
      #    (0.5..2.5).size  # TypeError
      #    (..1).size       # TypeError
      #
      #  Related: Range#count.
      def size
        unless @begin.respond_to?(:succ)
          raise TypeError, "can't iterate from #{@begin.class}"
        end

        # non-Integer range
        unless @begin.is_a?(Integer)
          return nil
        end

        # Integer range
        if @end == Float::INFINITY || @end.nil?
          Float::INFINITY
        elsif @begin > @end
          0
        else
          if @exclude_end
            @end.to_i - @begin
          else
            @end.to_i - @begin + 1
          end
        end
      end

      #  call-seq:
      #    step(s = 1) {|element| ... } -> self
      #    step(s = 1)                  -> enumerator/arithmetic_sequence
      #
      #  Iterates over the elements of range in steps of +s+. The iteration is performed
      #  by <tt>+</tt> operator:
      #
      #    (0..6).step(2) { puts _1 } #=> 1..5
      #    # Prints: 0, 2, 4, 6
      #
      #    # Iterate between two dates in step of 1 day (24 hours)
      #    (Time.utc(2022, 2, 24)..Time.utc(2022, 3, 1)).step(24*60*60) { puts _1 }
      #    # Prints:
      #    #   2022-02-24 00:00:00 UTC
      #    #   2022-02-25 00:00:00 UTC
      #    #   2022-02-26 00:00:00 UTC
      #    #   2022-02-27 00:00:00 UTC
      #    #   2022-02-28 00:00:00 UTC
      #    #   2022-03-01 00:00:00 UTC
      #
      #  If <tt> + step</tt> decreases the value, iteration is still performed when
      #  step +begin+ is higher than the +end+:
      #
      #    (0..6).step(-2) { puts _1 }
      #    # Prints nothing
      #
      #    (6..0).step(-2) { puts _1 }
      #    # Prints: 6, 4, 2, 0
      #
      #    (Time.utc(2022, 3, 1)..Time.utc(2022, 2, 24)).step(-24*60*60) { puts _1 }
      #    # Prints:
      #    #   2022-03-01 00:00:00 UTC
      #    #   2022-02-28 00:00:00 UTC
      #    #   2022-02-27 00:00:00 UTC
      #    #   2022-02-26 00:00:00 UTC
      #    #   2022-02-25 00:00:00 UTC
      #    #   2022-02-24 00:00:00 UTC
      #
      #  When the block is not provided, and range boundaries and step are Numeric,
      #  the method returns Enumerator::ArithmeticSequence.
      #
      #    (1..5).step(2) # => ((1..5).step(2))
      #    (1.0..).step(1.5) #=> ((1.0..).step(1.5))
      #    (..3r).step(1/3r) #=> ((..3/1).step((1/3)))
      #
      #  Enumerator::ArithmeticSequence can be further used as a value object for iteration
      #  or slicing of collections (see Array#[]). There is a convenience method #% with
      #  behavior similar to +step+ to produce arithmetic sequences more expressively:
      #
      #    # Same as (1..5).step(2)
      #    (1..5) % 2 # => ((1..5).%(2))
      #
      #  In a generic case, when the block is not provided, Enumerator is returned:
      #
      #    ('a'..).step('b')         #=> #<Enumerator: "a"..:step("b")>
      #    ('a'..).step('b').take(3) #=> ["a", "ab", "abb"]
      #
      #  If +s+ is not provided, it is considered +1+ for ranges with numeric +begin+:
      #
      #    (1..5).step { p _1 }
      #    # Prints: 1, 2, 3, 4, 5
      #
      #  For non-Numeric ranges, step absence is an error:
      #
      #    (Time.utc(2022, 3, 1)..Time.utc(2022, 2, 24)).step { p _1 }
      #    # raises: step is required for non-numeric ranges (ArgumentError)
      #
      #  For backward compatibility reasons, String ranges support the iteration both with
      #  string step and with integer step. In the latter case, the iteration is performed
      #  by calculating the next values with String#succ:
      #
      #    ('a'..'e').step(2) { p _1 }
      #    # Prints: a, c, e
      #    ('a'..'e').step { p _1 }
      #    # Default step 1; prints: a, b, c, d, e
      def step(s = UNDEFINED)
        if @begin.is_a?(Numeric) && s == 0
          raise ArgumentError, "step can't be 0"
        end

        unless block_given?
          if @begin.nil? && !(@end.is_a?(Numeric) && (s == UNDEFINED || s.is_a?(Numeric)))
            raise ArgumentError, '#step for non-numeric beginless ranges is meaningless'
          end

          return to_enum(:step, s) do
            unless ((@begin.is_a?(Numeric) && (@end.nil? || @end.is_a?(Numeric))) || (@begin.nil? && @end.is_a?(Numeric))) && (s == UNDEFINED || s.is_a?(Numeric)) # rubocop:disable Style/UnlessElse
              # generic case
              nil
            else
              # Numeric range and Numeric step

              if @begin.nil?
                raise TypeError, "nil can't be coerced into Integer"
              end

              if @end.nil?
                Float::INFINITY
              elsif (@begin <= @end && (s == UNDEFINED || s > 0)) || (@begin > @end && (s != UNDEFINED && s < 0))
                numerator = (@end - @begin).abs
                denominator = (s == UNDEFINED ? 1 : s.abs)

                size = (numerator / denominator) + 1

                if @exclude_end && (numerator % denominator <= Float::EPSILON) # numerator % denominator == 0
                  size -= 1
                end

                size
              else
                0
              end
            end
          end
        end

        if @begin.nil?
          raise ArgumentError, '#step iteration for beginless ranges is meaningless'
        end

        begin_as_string = to_string(@begin)
        if s == UNDEFINED && !@begin.is_a?(Numeric) && begin_as_string.nil? && !@begin.is_a?(Symbol)
          raise ArgumentError, 'step is required for non-numeric ranges'
        end

        # String range

        if !begin_as_string.nil? && (s.is_a?(Integer) || s == UNDEFINED)
          # backward range
          end_determinator = @exclude_end ? 0 : 1
          if !@end.nil? && (begin_as_string <=> @end) >= end_determinator # begin > end
            return self
          end

          if s == UNDEFINED
            s = 1
          end

          if s <= 0
            yield begin_as_string
            return self
          end

          current = begin_as_string
          if @exclude_end
            while @end.nil? || current < @end
              yield current
              s.times { current = current.succ }
            end
          else
            while @end.nil? || current <= @end
              yield current
              s.times { current = current.succ }
            end
          end

          return self
        end

        # Symbol range

        if @begin.is_a?(Symbol) && (s.is_a?(Integer) || s == UNDEFINED)
          # backward range
          end_determinator = @exclude_end ? 0 : 1
          if !@end.nil? && (@begin <=> @end) >= end_determinator # begin > end
            return self
          end

          if s == UNDEFINED
            s = 1
          end

          if s <= 0
            yield @begin
            return self
          end

          current = @begin
          if @exclude_end
            while @end.nil? || current < @end
              yield current
              s.times { current = current.succ }
            end
          else
            while @end.nil? || current <= @end
              yield current
              s.times { current = current.succ }
            end
          end

          return self
        end

        if @begin.is_a?(Numeric) && s == UNDEFINED
          s = 1
        end

        # check that the step moves iteration in the same direction as
        # from begin to end; otherwise, the iteration should be empty
        if !@end.nil? && @begin != -Float::INFINITY && (@begin <=> @end) != (@begin <=> (@begin + s))
          return self
        end

        # Numeric backward range with Numeric step

        if @begin.is_a?(Numeric) && s.is_a?(Numeric) && s < 0
          end_determinator = @exclude_end ? 0 : -1
          current = @begin

          while @end.nil? || (current <=> @end) > end_determinator
            yield current
            current += s
          end

          return self
        end

        # Float range or Numeric range with Float step

        if @begin.is_a?(Numeric) && s.is_a?(Numeric) && (@begin.is_a?(Float) || (@end.is_a?(Float) || s.is_a?(Float)))
          if @end.nil? || (@begin <=> @end) <= 0
            # forward range
            end_determinator = @exclude_end ? 0 : 1

            n = 0
            current = @begin
            while @end.nil? || (current <=> @end) < end_determinator
              yield current.to_f

              n += 1
              current = @begin + (n * s)
            end
          else
            # backward range
            end_determinator = @exclude_end ? 0 : -1

            n = 0
            current = @begin
            while (current <=> @end) > end_determinator
              yield current.to_f

              n += 1
              current = @begin + (n * s)
            end
          end

          return self
        end

        # generic case

        current = @begin
        if @end.nil? || (@begin <=> @end) <= 0
          # forward range

          # termination condition:
          # - current >= end (when exclude end)
          # - current > end (when not exclude end)
          end_determinator = @exclude_end ? 0 : 1

          while @end.nil? || (current <=> @end) < end_determinator
            yield current
            current += s
          end
        else
          # backward range

          # termination condition:
          # - current <= end (when exclude end)
          # - current < end (when not exclude end)
          end_determinator = @exclude_end ? 0 : -1

          while (current <=> @end) > end_determinator
            yield current
            current += s
          end
        end

        self
      end

      #  call-seq:
      #    to_a -> array
      #
      #  Returns an array containing the elements in +self+, if a finite collection;
      #  raises an exception otherwise.
      #
      #    (1..4).to_a     # => [1, 2, 3, 4]
      #    (1...4).to_a    # => [1, 2, 3]
      #    ('a'..'d').to_a # => ["a", "b", "c", "d"]
      def to_a
        if @end.nil?
          raise RangeError, 'cannot convert endless range to an array'
        end

        super
      end

      # call-seq:
      #   to_s -> string
      #
      # Returns a string representation of +self+,
      # including <tt>begin.to_s</tt> and <tt>end.to_s</tt>:
      #
      #   (1..4).to_s  # => "1..4"
      #   (1...4).to_s # => "1...4"
      #   (1..).to_s   # => "1.."
      #   (..4).to_s   # => "..4"
      #
      # Note that returns from #to_s and #inspect may differ:
      #
      #   ('a'..'d').to_s    # => "a..d"
      #   ('a'..'d').inspect # => "\"a\"..\"d\""
      #
      # Related: Range#inspect.
      def to_s
        begin_as_string = @begin ? @begin.to_s : ''
        end_as_string = @end ? @end.to_s : ''
        suffix = @exclude_end ? '...' : '..'

        begin_as_string + suffix + end_as_string
      end

      private

      def compare(a, b)
        determinator = block_given? ? yield(a, b) : a <=> b

        if determinator.nil?
          # MRI: rb_cmperr
          b_string = if b == true || b == false || b.nil? || b.is_a?(Integer) || b.is_a?(Float)
                       b.inspect
                     else
                       b.class.name
                     end

          raise ArgumentError, "comparison of #{a.class} with #{b_string} failed"
        end

        determinator
      end

      # MRI: rb_check_string_type
      def to_string(object)
        return object if object.is_a? String
        return nil    if object.nil?
        return nil    unless object.respond_to? :to_str

        as_string = object.to_str
        if as_string.nil?
          return nil
        end

        unless as_string.is_a? String
          raise TypeError, "can't convert #{object.class} to String (#{object.class}#to_str gives #{as_string.class})"
        end

        as_string
      end
    end
  end
end
