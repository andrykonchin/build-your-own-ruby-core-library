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

module RangeSpecs
  # doesn't support iteration, equivalent to WithoutSucc
  class Element
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(Element)

      @value <=> other.value
    end
  end

  class WithPlus
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(WithPlus)

      @value <=> other.value
    end

    def +(other)
      raise "does not support #{other}, only Step class" unless other.is_a?(Step)

      self.class.new(@value + other.value)
    end

    def ==(other)
      return false unless other.is_a?(WithPlus)

      @value == other.value
    end
  end

  class Step
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  # a range of WithSucc is iteratable by calling #succ
  class WithSucc
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(WithSucc)

      @value <=> other.value
    end

    def succ
      WithSucc.new(@value + 1)
    end

    def ==(other)
      return false unless other.is_a?(WithSucc)

      @value == other.value
    end
  end

  # a range of WithoutSucc cannot be iterated
  class WithoutSucc
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(WithoutSucc)

      @value <=> other.value
    end
  end

  # can be used as a boundary in a range of Strings
  class WithToStr
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      if other.is_a?(WithToStr)
        @value <=> other.value
      elsif other.is_a?(String)
        @value <=> other
      end
    end

    def to_str
      @value
    end
  end

  # IMPORTANT: it should not override #==
  class WithEql
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(WithEql)

      @value <=> other.value
    end

    def eql?(other)
      return false unless other.is_a?(WithEql)

      @value.eql?(other.value)
    end
  end

  # IMPORTANT: it should not override #eql?
  class WithEqualValue
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(WithEqualValue)

      @value <=> other.value
    end

    def ==(other)
      return false unless other.is_a?(WithEqualValue)

      @value == other.value
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

  # IMPORTANT: it doesn't implement #succ
  class Number < Numeric
    attr_reader :value

    def initialize(value) # rubocop:disable Lint/MissingSuper
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(Number)

      @value <=> other.value
    end

    def +(other)
      raise "supported Integer only, given #{other}" unless other.is_a?(Integer)

      Number.new(@value + other)
    end

    # needed only to compare arrays in specs
    def ==(other)
      return false unless other.is_a?(Number)

      @value == other.value
    end

    # to prevent type conversion
    undef_method :coerce
  end
end
