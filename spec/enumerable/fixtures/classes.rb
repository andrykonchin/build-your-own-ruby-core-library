require 'build_your_own/ruby_core_library/enumerable'

module EnumerableSpecs
  class Numerous
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def initialize(*list)
      @list = list.empty? ? [2, 5, 3, 6, 1, 4] : list
    end

    def each
      @list.each { |i| yield i }
    end
  end

  class NumerousWithSize < Numerous
    def size
      @list.size
    end
  end

  class EachWithParameters < Numerous
    attr_reader :arguments_passed

    def each(*arg)
      @arguments_passed = arg

      @list.each do |i|
        yield i
      end
    end
  end

  class EachCounter < Numerous
    attr_reader :times_called

    def initialize(*list)
      super
      @times_called = 0
    end

    def each(*_arg)
      @times_called += 1

      @list.each do |i|
        yield i
      end
    end
  end

  class Empty
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def each
    end
  end

  class EmptyWithSize
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def each
    end

    def size
      0
    end
  end

  class Equals
    def initialize(obj)
      @obj = obj
    end

    def ==(other)
      @obj == other
    end
  end

  class YieldsMulti
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def each
      yield 1, 2
      yield 3, 4, 5
      yield 6, 7, 8, 9
    end
  end

  class YieldsMultiWithFalse
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def each
      yield false, 2
      yield false, 4, 5
      yield false, 7, 8, 9
    end
  end

  class YieldsMultiWithSingleTrue
    include BuildYourOwn::RubyCoreLibrary::Enumerable

    def each
      yield false, 2
      yield true, 4, 5
      yield false, 7, 8, 9
    end
  end

  class ReverseComparable
    include Comparable

    attr_accessor :num

    def initialize(num)
      @num = num
    end

    # Reverse comparison
    def <=>(other)
      other.num <=> @num
    end
  end

  class Uncomparable
    def <=>(_other)
      nil
    end
  end

  class Pattern
    attr_reader :yielded

    def initialize(&block)
      @block = block
      @yielded = []
    end

    def ===(*args)
      @yielded << args
      @block.call(*args)
    end
  end

  class SetSubclass < Set
  end

  class SetSubclassWithParameters < Set
    attr_reader :arguments_passed

    def initialize(enum, *args, &)
      super(enum, &)
      @arguments_passed = args
    end
  end
end
