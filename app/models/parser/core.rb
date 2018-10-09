module Parser

	class Core
		attr_reader :results, :host, :starttime, :endtime

		def initialize(logfile)
			@source = logfile
		end

		def parse!
			catalog = []

			start = ""
			t_start = ""
			t_end = ""
			host = ""

			@source.each do |l|
				if m = start_matcher.match(l)
					start = "#{l[0..18]}"
					@starttime = Time.parse(start)
					host = m.captures.first # hostname

					# pp host
				end

				if block_start_matcher.match(l)
				    start = "#{l[0..18]}"
				end

				if m = checkpoint_matcher.match(l)
					catalog << [ m.captures.first, start, l[0..18], (Time.parse(l[0..18]) - Time.parse(start)) ]

					start = l[0..18]
				end

				if m = end_matcher.match(l)
					@endtime = Time.parse(l[0..18])
				end
			end

			@results = Layout.layout(catalog)
			@host = host
		end

		def start_matcher
			# matches the start of a puppet provisioning block on an npe ec2
			/Creating a new SSL key for (\w+\.\w+\.\w+)/
		end

		def block_start_matcher
			# matches the start of the service provisioning stage in puppet's logs
			/npe-apt-update-cache.*executed successfully/
		end

		def checkpoint_matcher
			# matches the point at which puppet has provisioned and restarted a service
			/Unscheduling refresh on Service\[([\w-]+)\]/
		end
	end

	class Puppet3Parser < Core

		def end_matcher
			/Puppet \(notice\): Finished catalog run in/
		end
	end

	class Puppet5Parser < Core

		def end_matcher
			/Puppet \(notice\): Applied catalog in/
		end
	end
end