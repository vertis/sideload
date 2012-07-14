#!/usr/bin/env ruby
require 'bundler/setup'

def run(cmd)
  puts cmd if ENV['DEBUG']
  Open3.popen3(cmd) {|stdin, stdout, stderr, wait_thr|
    @exit_status = wait_thr.value # Process::Status object returned.
  }
  @exit_status
end

# Temporary solution to keep our enterprise URL out of github
def base_url
  @config ||= YAML.load(File.read('config/sideload.yml'))
  @config['base_url']
end

def update_from_remote(gitdir, org, repo)
  result = run("cd #{gitdir} && git remote update --prune")
end

def mirror(gitdir, org, repo)
  result = run("git clone --mirror #{base_url}#{org}/#{repo}.git #{gitdir}")
end

def archive(gitdir, org, repo, commit_id='HEAD', prefix=nil, path=nil)
  cmd = []
  cmd << "git archive --format=tar --remote='#{gitdir}'"
  cmd << "--prefix='#{prefix}'" if prefix
  cmd << "'#{[commit_id, path].compact.join(":")}'"
  cmd << "> /tmp/git-tars/#{org}-#{repo}-#{commit_id}.tar"
  `mkdir -p /tmp/git-tars/`
  run(cmd.join(" "))
end

abort("No repos supplied") if ARGV.empty?

name = ARGV.first
org, repo = name.strip.split "/"
gitdir =  "/tmp/git/#{org}/#{repo}.git"
if File.exists?(gitdir)
  puts "Already exists, fetching from: #{name}" if ENV['DEBUG']
  update_from_remote(gitdir, org, repo)
else
  `mkdir -p /tmp/git/#{org}/#{repo}.git`
  puts "Mirroring from: #{name}" if ENV['DEBUG']
  mirror gitdir, org, repo
end
archive(gitdir, org, repo, 'HEAD', "#{repo}/", "spec")

