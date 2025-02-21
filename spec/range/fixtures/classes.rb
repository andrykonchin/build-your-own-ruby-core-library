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

  # a range of WithPlus is iteratable by calling #+
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

  # a range of WithPlus is iteratable by calling #succ
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

    # to prevent type conversion
    undef_method :coerce
  end

  class TenfoldSucc
    include Comparable

    attr_reader :n

    def initialize(n)
      @n = n
    end

    def <=>(other)
      @n <=> other.n
    end

    def succ
      self.class.new(@n * 10)
    end
  end

  # Custom Range classes Xs and Ys
  class Custom
    include Comparable
    attr_reader :length

    def initialize(n)
      @length = n
    end

    def eql?(other)
      inspect.eql? other.inspect
    end
    alias == eql?

    def inspect
      'custom'
    end

    def <=>(other)
      @length <=> other.length
    end
  end

  # represent a string of 'x's
  class Xs < Custom
    def succ
      Xs.new(@length + 1)
    end

    def inspect
      'x' * @length
    end
  end

  # represent a string of 'y's
  class Ys < Custom
    def succ
      Ys.new(@length + 1)
    end

    def inspect
      'y' * @length
    end
  end

  class MyRange < Range
  end

  class ComparisonError < RuntimeError
  end
end
