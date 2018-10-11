class ChartController < ApplicationController
  
  def new

  end

  def create
  	# Rails.logger.info params.inspect

  	version = params[:puppet_v3] && params[:puppet_v3].to_i == 1  ? :v3 : :v5

    body = params[:logfile]&.[](:body)

    if body&.length > 0

    	begin
    		b = CGI::unescape(params[:logfile][:body])

    		@manifest = ManifestRun.new(b.split("\n"), params.except(:logfile).merge(version: version))

    		@manifest.parse!

    		@manifest

    	rescue Exception => e
    		Rails.logger.error(e)
        Rails.logger.error(e.backtrace.join("\n"))

    		flash[:error] = "Error parsing log file: #{e.message}"

    		redirect_to "/chart"
    	end
    else

      flash[:notice] = "You must provide a puppet log extract to parse"

      redirect_to "/chart"
    end

  end
end
