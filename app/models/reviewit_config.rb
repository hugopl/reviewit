class ReviewitConfig
  CONFIG_FILE = './config/reviewit.yml'

  class << self
    private

    def data
      @data ||= load_data
    end

    def load_data
      data = read_yaml
      data.merge!(data[Rails.env]) if data.key?(Rails.env)
      data.symbolize_keys!
    end

    def read_yaml
      YAML.load_file(CONFIG_FILE) || {}
    rescue Errno::ENOENT
      warn("#{RPM_CONFIG_FILE} not found! Using default values")
      {}
    end

    def method_missing(symbol, *args)
      if args.empty?
        data[symbol]
      else
        return super unless symbol.to_s.ends_with?('=')
        data[symbol.to_s.chop.to_sym] = args.first
      end
    end
  end
end
