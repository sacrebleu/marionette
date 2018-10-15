# frozen_string_literal: true

module Parser
  # Core is the root class of the parsers for Puppet logs
  class Core
    attr_reader :results, :host, :starttime, :endtime, :options

    def initialize(logfile, options = {})
      @source = logfile
      @options = options
    end

    def parse!
      catalog = []

      start = ''
      t_start = ''
      t_end = ''
      host = ''

      @source.each do |l|
        if m = start_matcher.match(l)
          start = (l[0..18]).to_s
          @starttime = Time.parse(start)
          host = m.captures.first # hostname
        end

        start = (l[0..18]).to_s if block_start_matcher.match?(l)

        if m = checkpoint_matcher.match(l)
          catalog << [m.captures.first, start, l[0..18], (Time.parse(l[0..18]) - Time.parse(start))]

          start = l[0..18]
        end

        if m = end_matcher.match(l)
          Rails.logger.info("+ Found endpoint: #{l[0..18]}")
          @endtime = Time.parse(l[0..18])
        end
      end

      if options[:merge_similar] && options[:merge_similar] == '1'
        Rails.logger.info('+ Merging similar catalog entries')
        catalog = merge catalog
      end

      @results = Layout.layout(catalog)
      @host = host
    end

    def merge(precursor)
      merged = {}

      precursor.each do |a|
        k = a[0]
        if merged[k]
          merged[k][2] = a[2] if a[2]
          merged[k][3] += a[3]
        else
          merged[k] = a
        end
      end

      merged.values
    end

    def start_matcher
      # matches the start of a puppet provisioning block on an npe ec2
      /Creating a new SSL key for (\w+\.\w+(\.\w+)?)/
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

  class Puppet6Parser < Core
    def end_matcher
      /Puppet \(notice\): Applied catalog in/
    end
  end
end
