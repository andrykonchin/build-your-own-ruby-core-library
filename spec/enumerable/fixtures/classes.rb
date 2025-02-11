# Copyright (c) 2008 Engine Yard, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

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
