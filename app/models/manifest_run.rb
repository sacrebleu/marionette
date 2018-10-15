# frozen_string_literal: true

require 'parser/core'

class ManifestRun
  attr_reader :starttime, :host, :endtime, :parser

  def initialize(logfile, options = { version: :v6 })
    Rails.logger.info "+ Parsing Puppet version: #{options[:version]}"

    @parser = case options[:version]
              when :v3
                Parser::Puppet3Parser.new(logfile, options)
              else
                Parser::Puppet6Parser.new(logfile, options)
              end
  end

  def parse!
    @parser.parse!

    @starttime = @parser.starttime
    @endtime = @parser.endtime
    @data = @parser.results
    @host = @parser.host
  end

  def title
    "Provisioning #{host}"
  end

  def subtitle
    "Puppet run started #{starttime.strftime('%Y-%m-%d %H:%M:%S')} duration: #{endtime - starttime}s"
  end

  def domain
    @domain ||= @data.collect { |e| e[0] }
  end

  def range
    i = 0.0
    n = domain.length
    res = []
    domain.length.times { res << i; i += (1.0 / (n > 1 ? n - 1 : 1) * 10_000).floor / 10_000.0 }
    res
  end

  def results
    @results ||= JSON.generate(@data.collect { |e| { label: e[0], value: e[3] } })
  end
end
