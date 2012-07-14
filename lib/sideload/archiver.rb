require 'pathname'
module Sideload
  class Archiver
    attr_accessor :base_url, :org, :repo, :basedir, :repodir, :archivedir, :archivefile

    def initialize(base_url, organization, repository, options={})
      @base_url = base_url
      @org = organization
      @repo = repository
      @basedir = Pathname.new(options[:basedir] || 'tmp/git')

      @repodir = @basedir+"#{org}/#{repo}.git"
      @repodir.parent.mkpath

      @archivedir = Pathname.new(options[:archivedir] || 'tmp/git-tars')
      @archivedir.mkpath
    end

    def archive(commit_id='HEAD', path=nil)
      commit_id = resolve_head[0..9] if commit_id=='HEAD'
      pathslug = path.gsub('/','-') if path
      archivename = ([org, repo, commit_id, pathslug].compact.join('-') + ".tar")
      @archivefile = archivedir + archivename
      return archivefile if File.exists?(archivefile)
      if File.exists?(repodir)
        puts "Already exists, fetching from: #{org}/#{repo}" if ENV['DEBUG']
        update_from_remote
      else
        puts "Mirroring from: #{org}/#{repo}" if ENV['DEBUG']
        mirror
      end
      create_archive(commit_id, path)
      return archivefile
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

    def update_from_remote
      run("cd #{repodir} && git remote update --prune")
    end

    def mirror
      run("git clone --mirror #{base_url}/#{org}/#{repo}.git #{repodir}")
    end

    def create_archive(commit_id='HEAD', path=nil)
      cmd = []
      cmd << "git archive --format=tar --remote='#{repodir}' --prefix='#{repo}/'"
      cmd << "'#{[commit_id, path].compact.join(":")}'"
      cmd << "> #{archivefile}"
      run(cmd.join(" "))
    end
  end
end