require 'sinatra'
require 'resque'
require 'resque-status'
require 'resque/status'

module Sideload
  class App < Sinatra::Base
    get '/:org/:repo/tarball/:commit' do
      jobid = Sideload::ArchiveJob.create(:org => params[:org], :repo => params[:repo], :commit => params[:commit], :filter => params[:filter], :prefix => params[:prefix])
      redirect "/download/#{jobid}", 302
    end

    get '/download/:jobid' do
      while(true)
        status = Resque::Plugins::Status::Hash.get(params[:jobid])
        break if status["status"]=="completed"
        sleep 0.5
      end
      send_file status['file'], :filename => File.basename(status['file']), :disposition => :inline
    end
  end
end