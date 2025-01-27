module BuildYourOwn
  module RubyCoreLibrary
    #Enumerable = ::Enumerable
    module Enumerable
      UNDEFINED = Object.new
      private_constant :UNDEFINED

      LONG_MAX = 2147483647 # 2^31 - 1
      private_constant :LONG_MAX

      def all?(pattern = UNDEFINED)
        each do |*rest|
          value = single_block_arg(rest)

          check_result = \
            if pattern == UNDEFINED && block_given?
              yield *value
            elsif pattern == UNDEFINED && !block_given?
              !!value
            elsif pattern != UNDEFINED
              warn "given block not used" if block_given?
              pattern === value
            end

          return false unless check_result
        end

        true
      end

      def any?(pattern = UNDEFINED)
        each do |*rest|
          value = single_block_arg(rest)

          check_result = \
            if pattern == UNDEFINED && block_given?
              yield *value
            elsif pattern == UNDEFINED && !block_given?
              !!value
            elsif pattern != UNDEFINED
              warn "given block not used" if block_given?
              pattern === value
            end

          return true if check_result
        end

        false
      end

      def chain(*enums)
        Enumerator::Chain.new(self, *enums)
      end

      def chunk
        return to_enum(:chunk) { enumerator_size } unless block_given?

        Enumerator.new do |y|
          value = nil
          chunk = []

          each do |*rest|
            e = single_block_arg(rest)
            block_result = yield e

            if block_result == :_separator || block_result == nil
              unless chunk.empty?
                y << [value, chunk]
                value = nil
                chunk = []
              end

              next
            end

            if block_result == :_alone
              unless chunk.empty?
                y << [value, chunk]
                value = nil
                chunk = []
              end

              y << [:_alone, [e]]
              next
            end

            if block_result.is_a?(Symbol) && block_result.start_with?("_")
              raise "symbols beginning with an underscore are reserved"
            end

            if chunk.empty? # so it's the first chunk
              value = block_result
              chunk << e
            elsif value == block_result # continue current chunk
              chunk << e
            else # return current chunk and start a new one
              y << [value, chunk]
              value = block_result
              chunk = [e]
            end
          end

          # the last not finished chunk
          unless chunk.empty?
            y << [value, chunk]
          end
        end
      end

      def chunk_while
        unless block_given?
          raise ArgumentError, "tried to create Proc object without a block"
        end

        Enumerator.new do |y|
          current_chunk = []
          previous = UNDEFINED

          each do |*rest|
            e = single_block_arg(rest)

            if previous == UNDEFINED
              current_chunk << e
            else
              if yield(previous, e)
                current_chunk << e
              else
                y << current_chunk
                current_chunk = [e]
              end
            end

            previous = e
          end

          unless current_chunk.empty?
            y << current_chunk
          end
        end
      end

      def compact
        array = []
        each do |*rest|
          value = single_block_arg(rest)
          array << value if value != nil
        end

        array
      end

      def count(object = UNDEFINED)
        if object == UNDEFINED && !block_given?
          i = 0
          each { i += 1}
          return i
        end

        if object != UNDEFINED
          warn 'given block not used' if block_given?

          i = 0
          each do |*rest|
            value = single_block_arg(rest)
            i += 1 if object == value
          end
          return i
        end

        # block given
        i = 0
        each do |*rest|
          i += 1 if yield *rest
        end
        i
      end

      def cycle
        raise "Not implemented"
      end

      def drop(n)
        n = to_integer!(n)
        raise ArgumentError, "attempt to drop negative size" if n < 0
        raise RangeError, "bignum too big to convert into 'long'" if n > LONG_MAX

        array = []
        i = 0
        each do |*rest|
          if i < n
            i += 1
            next
          else
            array << single_block_arg(rest)
          end
        end

        array
      end

      def drop_while
        return to_enum(:drop_while) unless block_given?

        array = []
        skip = true
        each do |*rest|
          value = single_block_arg(rest)
          if skip
            skip &&= yield value
          end
          array << value unless skip
        end
        array
      end

      def each_cons
        raise "Not implemented"
      end

      def each_entry(*args)
        return to_enum(:each_entry, *args) { enumerator_size } unless block_given?

        each(*args) do |*rest|
          yield single_block_arg(rest)
        end

        self
      end

      def each_slice
        raise "Not implemented"
      end

      def each_with_index
        raise "Not implemented"
      end

      def each_with_object
        raise "Not implemented"
      end

      def entries(*args)
        array = []
        each(*args) do |*rest|
          element = single_block_arg(rest)
          array << element
        end
        array
      end
      alias_method :to_a, :entries

      def filter_map
        return to_enum(:filter_map) { enumerator_size } unless block_given?

        array = []
        each do |*rest|
          result = yield *rest
          array << result if result
        end
        array
      end

      def find_index
        raise "Not implemented"
      end

      def find
        raise "Not implemented"
      end
      alias_method :detect, :find

      def first(n = UNDEFINED)
        if n == UNDEFINED
          value = nil
          each do |*rest|
            value = single_block_arg(rest)
            break
          end
          value
        else
          take(n)
        end
      end

      def flat_map
        raise "Not implemented"
      end
      alias_method :collect_concat, :flat_map

      def grep
        raise "Not implemented"
      end

      def grep_v
        raise "Not implemented"
      end

      def group_by
        raise "Not implemented"
      end

      def include?(object)
        each do |*rest|
          element = single_block_arg(rest)

          if element == object
            return true
          end
        end

        false
      end
      alias_method :member?, :include?

      def inject
        raise "Not implemented"
      end
      alias_method :reduce, :inject

      def lazy
        raise "Not implemented"
      end

      def map
        return to_enum(:map) { enumerator_size } unless block_given?

        array = []
        each do |*rest|
          array << yield(*rest)
        end
        array
      end
      alias_method :collect, :map

      def max_by
        raise "Not implemented"
      end

      def max
        raise "Not implemented"
      end

      def min_by
        raise "Not implemented"
      end

      def min
        raise "Not implemented"
      end

      def minmax_by
        raise "Not implemented"
      end

      def minmax
        raise "Not implemented"
      end

      def none?(pattern = UNDEFINED)
        each do |*rest|
          value = single_block_arg(rest)

          check_result = \
            if pattern == UNDEFINED && block_given?
              yield *value
            elsif pattern == UNDEFINED && !block_given?
              !!value
            elsif pattern != UNDEFINED
              warn "given block not used" if block_given?
              pattern === value
            end

          return false if check_result
        end

        true
      end

      def one?(pattern = UNDEFINED)
        matches_count = 0

        each do |*rest|
          value = single_block_arg(rest)

          check_result = \
            if pattern == UNDEFINED && block_given?
              yield *value
            elsif pattern == UNDEFINED && !block_given?
              !!value
            elsif pattern != UNDEFINED
              warn "given block not used" if block_given?
              pattern === value
            end

          matches_count += 1 if check_result

          if matches_count >= 2
            return false
          end
        end

        matches_count == 1
      end

      def partition
        raise "Not implemented"
      end

      def reject
        return to_enum(:reject) { enumerator_size } unless block_given?

        array = []
        each do |*rest|
          value = single_block_arg(rest)
          array << value unless yield value
        end
        array
      end

      def reverse_each
        raise "Not implemented"
      end

      def select
        return to_enum(:select) { enumerator_size } unless block_given?

        array = []
        each do |*rest|
          value = single_block_arg(rest)
          array << value if yield value
        end
        array
      end
      alias_method :find_all, :select
      alias_method :filter, :select

      def slice_after
        raise "Not implemented"
      end

      def slice_before
        raise "Not implemented"
      end

      def slice_when
        raise "Not implemented"
      end

      def slice_when
        raise "Not implemented"
      end

      def sort_by
        return to_enum(:sort_by) { enumerator_size } unless block_given?

        touples = []
        each do |*rest|
          touples << [rest[0], yield(single_block_arg(rest))]
        end

        # bubble sort
        (0..touples.size - 2).each do |i|
          (i+1..touples.size - 1).each do |j|
            determinator = touples[i][1] <=> touples[j][1]
            if determinator.nil?
              raise ArgumentError, "comparison of #{touples[i][1].class} with #{touples[j][1].class} failed"
            end

            if (determinator) > 0 # that's touples[i][1] > touples[j][1]
              touples[i], touples[j] = touples[j], touples[i]
            end
          end
        end

        touples.map { |t| t[0] }
      end

      def sort
        array = []
        each do |*rest|
          array << single_block_arg(rest)
        end

        # bubble sort
        (0..array.size - 2).each do |i|
          (i+1..array.size - 1).each do |j|
            determinator = block_given? ? yield(array[i], array[j]) : array[i] <=> array[j]
            if determinator.nil?
              raise ArgumentError, "comparison of #{array[i].class} with #{array[j].class} failed"
            end

            if determinator > 0 # that's array[i] > array[j]
              array[i], array[j] = array[j], array[i]
            end
          end
        end

        array
      end

      def sum(initial_value = 0)
        result = initial_value

        each do |*rest|
          if block_given?
            result += yield single_block_arg(rest)
          else
            result += rest[0]
          end
        end

        result
      end

      def take(n)
        n = to_integer!(n)

        raise ArgumentError, "attempt to take negative size" if n < 0
        raise RangeError, "bignum too big to convert into 'long'" if n > LONG_MAX
        return [] if n == 0

        array = []
        each do |*rest|
          array << single_block_arg(rest)
          n -= 1
          break if n <= 0
        end
        array
      end

      def take_while
        return to_enum(:take_while) unless block_given?

        array = []
        each do |*rest|
          e = single_block_arg(rest)

          unless yield *rest
            return array
          end

          array << e
        end

        array
      end

      def tally(hash = {})
        hash = to_hash!(hash)
        if hash.frozen?
          raise FrozenError, "can't modify frozen Hash: #{hash}"
        end

        each do |*rest|
          e = single_block_arg(rest)

          if hash.has_key?(e)
            value = hash[e]
            unless value.is_a?(Integer)
              raise TypeError,  "wrong argument type #{value.class} (expected Integer)"
            end

            hash[e] = value + 1
          else
            hash[e] = 1
          end
        end

        hash
      end

      def to_h(*args)
        h = {}

        each(*args) do |*rest|
          if block_given?
            e = yield(*rest)
          else
            e = rest[0]
          end

          array = to_array(e)

          if array.nil?
            raise TypeError, "wrong element type #{e.class} (expected array)"
          end

          if array.size != 2
            raise ArgumentError, "element has wrong array length (expected 2, was #{array.size})"
          end

          key, value = array
          h[key] = value
        end

        h
      end

      def to_set(klass = Set, *args, &block)
        klass.new(self, *args, &block)
      end

      def uniq
        set = Set.new
        array = []

        each do |*rest|
          e = single_block_arg(rest)
          key = block_given? ? yield(*rest) : e

          unless set.include?(key)
            set << key
            array << e
          end
        end

        array
      end

      def zip(*enums)
        enumerators = enums.map do |e|
          unless e.respond_to?(:each)
            raise TypeError, "wrong argument type #{e.class} (must respond to :each)"
          end

          e.to_enum(:each)
        end

        arrays = []

        each do |*rest|
          e = single_block_arg(rest)
          array = [e]

          enumerators.each do |enumerator|
            begin
              value = enumerator.next
            rescue StopIteration
              value = nil
            end
            array << value
          end

          if block_given?
            yield array
          else
            arrays << array
          end
        end

        unless block_given?
          arrays
        end
      end

      private

      # CRuby: rb_enum_values_pack
      def single_block_arg(args)
        return nil if args.empty?
        return args[0] if args.size == 1
        args
      end

      def enumerator_size
        respond_to?(:size) ? size : nil
      end

      # CRuby: rb_num2long
      def to_integer!(object)
        return object if object.is_a? Integer
        raise TypeError, "no implicit conversion from nil to integer" if object.nil?
        raise TypeError, "no implicit conversion of #{object.class} into Integer" unless object.respond_to? :to_int

        value = object.to_int
        unless value.is_a? Integer
          raise TypeError, "can't convert #{object.class} to Integer (#{object.class}#to_int gives #{value.class})"
        end

        value
      end

      # CRuby: rb_check_array_type
      def to_array(object)
        return object if object.is_a? Array
        return nil if object.nil?
        return nil unless object.respond_to? :to_ary

        value = object.to_ary
        unless value.is_a? Array
          raise TypeError, "can't convert #{object.class} to Array (#{object.class}#to_ary gives #{value.class})"
        end

        value
      end

      # CRuby: rb_to_hash_type
      def to_hash!(object)
        return object if object.is_a? Hash
        raise TypeError, "no implicit conversion of #{object.class} into Hash" unless object.respond_to? :to_hash

        value = object.to_hash
        unless value.is_a? Hash
          raise TypeError, "can't convert #{object.class} to Hash (#{object.class}#to_hash gives #{value.class})"
        end

        value
      end
    end
  end
end
