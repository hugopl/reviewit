module ApplicationHelper
  def print_errors obj
    obj_str = obj.to_s
    obj_instance = instance_variable_get("@#{obj_str}")

    return nil unless obj_instance.errors.any?

    errors = obj_instance.errors.inject('') do |script, error|
      script += "Tipped.create('##{obj_str}_#{error[0]}', '#{escape_javascript(error[1])}', { position: 'topright', container: $('#error_tips')[0] });"
    end
    script = "$(document).ready(function() {#{errors}});"

    javascript_tag(script)
  end
end
