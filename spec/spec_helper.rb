require 'rubygems'
require 'bundler/setup'
require 'rack/test'
require 'rspec'
require 'json'
require 'pathname'
require 'rspec/autorun'
require 'fileutils'

require './lib/sideload'

FileUtils.rm_r('tmp/git') rescue nil
FileUtils.rm_r('tmp/git-tars') rescue nil

RSpec.configure do |config|
  
end