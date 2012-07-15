require 'yaml'

module Sideload
  class Config
    def initialize
      @config = YAML.load(File.read(Sideload.root+'config/sideload.yml'))
    end

    def base_url
      @config['base_url']
    end
  end
end