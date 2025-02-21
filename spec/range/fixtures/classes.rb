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
