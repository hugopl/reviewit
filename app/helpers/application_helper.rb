require 'digest/md5'

module ApplicationHelper
  def print_errors obj
    obj_str = obj.to_s
    obj_instance = instance_variable_get("@#{obj_str}")
    obj_instance = send(obj) if obj_instance.nil?

    return nil unless obj_instance.errors.any?

    errors = obj_instance.errors.inject('') do |script, error|
      script + "Tipped.create('##{obj_str}_#{error[0]}', '#{escape_javascript(error[1])}', { position: 'topright', container: $('#error_tips')[0] });"
    end
    script = "$(document).ready(function() {#{errors}});"

    javascript_tag(script)
  end

  def under_index_of? section
    path_info.include? section
  end

  def under? section
    index = path_info.index section
    index and index < (path_info.count - 1) and path_info[index + 1] =~ /\A\d+\z/
  end

  def gravatar_url user, size = 40
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}?s=#{size}"
  end

  private

  def path_info
    @path_info ||= request.env['PATH_INFO'].split('/')
  end
end
