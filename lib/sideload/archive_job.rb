require 'resque'
require 'resque-status'
require 'resque/job_with_status'

module Sideload
  class ArchiveJob
    include Resque::Plugins::Status

    def perform
      archiver = Sideload::Archiver.new(Sideload.config.base_url, options["org"], options["repo"])
      file = archiver.archive(options["commit"])
      completed("file" => file.to_s)
    end
  end
end