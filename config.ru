require 'rubygems'
require 'bundler/setup'
require './lib/sideload'

if ENV['RACK_ENV']=='production'
  use Rack::CommonLogger, $stdout
end

run Rack::URLMap.new(
    '/' => Sideload::App
)