$:.unshift File.dirname(__FILE__)

module Sideload
  autoload :Archiver, 'sideload/archiver'
  autoload :App, 'sideload/app'
  autoload :ArchiveJob, 'sideload/archive_job'
end