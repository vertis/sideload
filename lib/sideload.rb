$:.unshift File.dirname(__FILE__)

module Sideload
  autoload :Archiver, 'sideload/archiver'
  autoload :App, 'sideload/app'
  autoload :ArchiveJob, 'sideload/archive_job'
  autoload :Config, 'sideload/config'

  def self.root
    Pathname.new(File.dirname(__FILE__)).expand_path.parent
  end

  def self.config
    @config ||= Sideload::Config.new
  end
end