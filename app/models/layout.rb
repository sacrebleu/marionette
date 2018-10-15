# frozen_string_literal: true

class Layout
  # lays out puppet provisioning steps in alternating order by duration, to permit the generation of a balanced
  # pie chart
  # 1. takes a list of 4 element arrays, sorting by the last field.
  # 2. selects the first element into the output list
  # calculates the sum of the elements excluding the largest two elements, and halves this - this is the *half_sum*
  # 3. staggers the remaining n-2 elements into the output list by next-largest, next-smallest in order.  When
  # the sum of elements added reaches the half-sum, the second-largest element is inserted into the list, and the
  # zip of the remainder of the elements continues from where it was interrupted.
  def self.layout(data)
    return data if data.length < 2

    a = data.sort { |x, y| y[3] <=> x[3] }

    res = [a.first]

    half_partial_sum = a[2..-1].reduce(0) { |i, x| i + x[3] } / 2 # mean of all the samples less the largest two

    # take the remainder of the list excluding the two largest entries
    remainder = a[2..-1]

    # take the lower half of this list
    highers = a[2..(remainder.length / 2) + 1]
    lowers  = a[(remainder.length / 2 + 2)..-1].reverse

    accumulator = 0
    i = 0
    set = false

    while i < [highers.length, lowers.length].max

      if i < lowers.length
        res << lowers[i]
        accumulator += lowers[i][3]

        if accumulator >= half_partial_sum && !set ## append the second largest value if we've reached the half partial sum
          res << a[1]
          set = true
        end
      end

      if i < highers.length
        res << highers[i]
        accumulator += highers[i][3]

        if accumulator >= half_partial_sum && !set ## append the second largest value if we've reached the half partial sum
          res << a[1]
          set = true
        end
      end

      i += 1
    end

    res
  end
end
