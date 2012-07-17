require 'open3'
require 'pathname'

module Sideload
  class Archiver
    attr_accessor :base_url, :org, :repo, :basedir, :repodir, :archivedir, :archivefile

    def initialize(base_url, organization, repository, options={})
      begin
        @base_url = base_url
        @org = organization
        @repo = repository
        @basedir = Pathname.new(options[:basedir] || 'tmp/git').expand_path
        @basedir.mkpath
        (@basedir+org).mkpath

        @repodir = @basedir+"#{org}/#{repo}.git"
        

        @archivedir = Pathname.new(options[:archivedir] || 'tmp/git-tars').expand_path
        @archivedir.mkpath
      rescue => ex
        puts ex.message
        puts ex.backtrace
        raise ex
      end
    end

    def archive(commit_id='HEAD', options={})
      begin
        cache_repository

        commit_id = resolve_head[0..9] if commit_id=='HEAD'
        commitslug = commit_id.gsub('/','-').gsub('#','-')
        filterslug = options[:filter].gsub('/','-') if options[:filter]
        pathslug = options[:path].gsub('/','-') if options[:path]
        archivename = ([org, repo, commitslug, filterslug, pathslug, Time.now.to_i].compact.join('-') + ".tar")
        @archivefile = archivedir + archivename
        #return archivefile if File.exists?(archivefile)

        create_archive(commit_id, options)
        return archivefile
      rescue => ex
        puts ex.message
        puts ex.backtrace
        raise ex
      end
    end

    private
    def run(cmd)
      puts cmd if ENV['DEBUG']
      Open3.popen3(cmd) {|stdin, stdout, stderr, wait_thr|
        @exit_status = wait_thr.value # Process::Status object returned.
      }
      @exit_status
    end

    def resolve_head
      %x[git --git-dir=#{repodir} rev-parse HEAD]
    end

    def cache_repository
      if File.exists?(repodir+'HEAD')
        puts "Already exists, fetching from: #{org}/#{repo}" if ENV['DEBUG']
        update_from_remote
      else
        repodir.rmtree rescue nil
        puts "Mirroring from: #{org}/#{repo}" if ENV['DEBUG']
        mirror
      end
    end

    def update_from_remote
      run("cd #{repodir} && git remote update --prune")
    end

    def mirror
      run("git clone --mirror #{base_url}/#{org}/#{repo}.git #{repodir}")
    end

    def create_archive(commit_id='HEAD', options={})
      cmd = []
      cmd << "git archive --format=tar --remote='#{repodir}'"
      cmd << "--prefix='#{options[:prefix]}/'" if options[:prefix]
      cmd << "'#{[commit_id, options[:filter]].compact.join(":")}'"
      cmd << options[:path] if options[:path]
      cmd << "> #{archivefile}"
      run(cmd.join(" "))
    end
  end
end