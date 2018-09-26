class Layout
	# lays out puppet provisioning steps in alternating order by duration, to permit the generation of a balanced
	# pie chart
	def self.layout(data)
		a = data.sort {|a,b| b[3] <=> a[3] }

		res = [a.first]

		l = a.length-1

		half_partial_sum = a[2..-1].reduce(0) { |i,a| i + a[3] } / 2 # mean of all the samples less the largest two

		# take the remainder of the list excluding the two largest entries
		remainder = a[2..-1]

		# take the lower half of this list

		highers = a[2..(remainder.length/2)+1]
		lowers  = a[(remainder.length/2 + 2)..-1].reverse

		accumulator = 0
		i = 0
		set = false

		while i < [highers.length, lowers.length].max do

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

				if accumulator >= half_partial_sum && !set  ## append the second largest value if we've reached the half partial sum
					res << a[1]
					set = true
				end
			end

			i += 1
		end

		res
	end
end