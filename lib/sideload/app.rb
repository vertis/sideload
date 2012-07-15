require 'sinatra'
require 'resque'
require 'resque-status'
require 'resque/status'

module Sideload
  class App < Sinatra::Base
    get '/:org/:repo/tarball/:commit' do
      jobid = Sideload::ArchiveJob.create(:org => params[:org], :repo => params[:repo], :commit => params[:commit])
      redirect "/download/#{jobid}", 302
    end

    get '/download/:jobid' do
      status = Resque::Plugins::Status::Hash.get(params[:jobid])
      case status["status"]
      when "completed"
        send_file status['file'], :filename => File.basename(status['file']), :disposition => :attachment
      when "failed"
        status["message"]
      when "queued"
        "<html><head><meta http-equiv=\"refresh\" content=\"5\"></head></html>"
      when "working"
        "<html><head><meta http-equiv=\"refresh\" content=\"5\"></head></html>"
      end
    end
  end
end