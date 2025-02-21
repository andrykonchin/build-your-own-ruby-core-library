module RangeSpecs
  # a range of Element isn't iteratable
  class Element
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      return nil unless other.is_a?(Element)
      @value <=> other.value
    end

    def ==(other)
      return false unless other.is_a?(Element)
      @value == other.value
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

    def +(step)
      unless step.is_a?(Step)
        raise "does not support #{step}, only Step class"
      end

      self.class.new(@value + step.value)
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
      else
        nil
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
    alias :== :eql?

    def inspect
      'custom'
    end

    def <=>(other)
      @length <=> other.length
    end
  end

  class Xs < Custom # represent a string of 'x's
    def succ
      Xs.new(@length + 1)
    end

    def inspect
      'x' * @length
    end
  end

  class Ys < Custom # represent a string of 'y's
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
