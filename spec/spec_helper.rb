require 'rubygems'
require 'bundler/setup'
require 'rack/test'
require 'rspec'
require 'json'
require 'pathname'
require 'rspec/autorun'
require 'fileutils'

require './lib/sideload'

FileUtils.rm_r('tmp/git')
FileUtils.rm_r('tmp/git-tars')

RSpec.configure do |config|
  
end