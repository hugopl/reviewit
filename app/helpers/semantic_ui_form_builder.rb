class SemanticUiFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, to: :@template

  def text(method, options = {})
    base_text(method, options)
  end

  def email(method, options = {})
    options[:type] = 'email'
    base_text(method, options)
  end

  def password(method, options = {})
    options[:type] = 'password'
    base_text(method, options)
  end

  def timezone(method, options = {})
    select = time_zone_select(:time_zone, nil, { default: options[:value], model: TZInfo::Timezone }, class: 'select2select')
    base_field(method, options, select)
  end

  def inline_dropdown(method, options = {})
    options[:name] ||= "#{@object_name}[#{method}]"
    options[:value] ||= ''
    '<div class="ui inline dropdown">' \
      "<input type=\"hidden\" name=\"#{options[:name]}\" value=\"#{options[:value]}\">" \
      '<div class="text"></div>' \
      '<i class="dropdown icon"></i>'\
      '<div class="menu">' \
        '<div class="ui icon search input">' \
          '<i class="search icon"></i>' \
          '<input type="text" placeholder="Search...">' \
        '</div>' \
        "#{inline_dropdown_items(options)}" \
      '</div>' \
    '</div>'.html_safe
  end

  private

  def inline_dropdown_items(options)
    options[:options].map do |text, value|
      content_tag(:div, text, class: 'item', 'data-value' => value || text)
    end.reduce(&:+)
  end

  def id(method)
    "#{@object_name}_#{method}"
  end

  def base_text(method, options)
    html_args = { id: id(method), placeholder: options[:placeholder] }
    html_args[:autofocus] = true if options[:autofocus]
    html_args[:type] ||= options[:type] if options.key?(:type)
    html_args[:name] ||= "#{@object_name}[#{method}]"
    html_args[:value] ||= @object.send(method)

    content = content_tag(:input, '', html_args)
    if options[:action_button]
      content = content_tag(:div, class: 'ui action input') do
        content + content_tag(:button, options[:action_button], class: 'ui primary button')
      end
    end

    base_field(method, options, content)
  end

  def base_field(method, options, content)
    label_text = options[:label] || method.to_s.titleize
    label = if options[:info]
              content_tag(:label, for: id(method)) do
                label_text.html_safe + content_tag(:em, "(#{options[:info]})")
              end
            else
              content_tag(:label, label_text, for: id(method))
            end

    section_css = 'field'
    error_label = ''

    if @object.errors[method].any?
      section_css += ' error'
      messages = @object.errors[method].join(', ')
      error_label = content_tag(:div, messages, class: 'ui pointing red basic label')
    end
    content_tag(:div, (label + content + error_label).html_safe, class: section_css)
  end
end
