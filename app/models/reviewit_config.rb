# Please, use just plain ruby here, no rails code, since this is loaded into application.rb
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
      data.deep_symbolize_keys!
      apply_defaults(data)
      apply_open_structs(data)
      data
    end

    def apply_open_structs(data)
      data.each do |k, v|
        next unless v.is_a?(Hash)

        data[k] = OpenStruct.new(v)
      end
    end

    def apply_defaults(data)
      data[:mail] ||= {}
      data[:mail][:domain] ||= 'localhost'
      data[:mail][:sender] ||= 'foobar@example.com'
      data[:mail][:delivery_method] ||= 'file'
      data[:secret_key] ||= SecureRandom.hex(64)
    end

    def read_yaml
      path = Rails.root.join(CONFIG_FILE)
      YAML.load_file(path) || {}
    rescue Errno::ENOENT
      warn("#{path} not found! Using default values")
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
