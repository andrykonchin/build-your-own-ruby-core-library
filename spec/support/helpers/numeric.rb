def nan_value
  0 / 0.0
end

def infinity_value
  1 / 0.0
end

def bignum_value(plus = 0)
  # Must be >= fixnum_max + 2, so -bignum_value is < fixnum_min
  # A fixed value has the advantage to be the same numeric value for all Rubies and is much easier to spec
  (2**64) + plus
end
