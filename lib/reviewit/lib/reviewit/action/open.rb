module Reviewit
  class Open < Action
    def run
      mr_id = options[:mr]
      mr_id ||= mr_id_from_head
      raise 'There are no merge request on HEAD and you didn\'t specified one.' if mr_id.nil?

      command = case RbConfig::CONFIG['host_os']
                when /linux|bsd/ then 'xdg-open'
                when /darwin/ then 'open'
                when /mswin|mingw|cygwin/ then 'start'
                else
                  raise 'Unknow OS'
                end

      fork do
        link = api.mr_url(mr_id)
        system("#{command} #{link}")
      end
    end

    private

    def parse_options
      Trollop.options {}
      mr = ARGV.shift
      { mr: mr }
    end
  end
end
