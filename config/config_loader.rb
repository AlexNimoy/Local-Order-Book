require 'yaml'

module Binance
  class ConfigLoader
    @instance = new
    private_class_method :new
     
    def self.instance
      @instance
    end

    def config
      @config ||= YAML.load_file(File.join(__dir__, 'config.yml'))
    end

    def find_pair(pair)
      config['currency_pairs'].reduce({}) { |h, v| h.merge v }[pair]
    end

    def currency_pairs
      config['currency_pairs']
    end
  end
end
