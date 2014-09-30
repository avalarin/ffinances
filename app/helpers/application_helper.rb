module ApplicationHelper

  def get_html_attributes base_css = "", options = {}, defaults = {}
    html = options[:html] || {}
    if html[:class] && base_css
      html[:class] = base_css + " " + html[:class]
    elsif base_css
      html[:class] = base_css
    end
    defaults.each { |k, v| html[k] = v }
    if (options[:data] && options[:data].class == Hash)
      options[:data].each do |k, v|
        html["data-" + k.to_s] = v
      end
    end
    html
  end

end
