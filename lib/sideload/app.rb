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
      while status["status"]!="completed"
        sleep 1
      end
      send_file status['file'], :filename => File.basename(status['file']), :disposition => :inline
    end
  end
end