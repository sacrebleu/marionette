class ChartController < ApplicationController
  
  def new

  end

  def create
  	# Rails.logger.info params.inspect

  	version = params[:puppet_v3] && params[:puppet_v3].to_i == 1  ? :v3 : :v5

  	Rails.logger.info "Puppet version: #{version}"

  	begin
  		b = CGI::unescape(params[:logfile][:body])

  		@manifest = ManifestRun.new(b.split("\n"))

  		@manifest.parse!

  		@manifest

  	rescue Exception => e
  		Rails.logger.error(e)

  		flash[:error] = "Error parsing log file: #{e.message}"

  		redirect_to "/chart"
  	end

  end
end
