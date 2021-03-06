module BootstrapHelpers
  module Builders
    class Icon < Base
      
      def render
        name = options[:name]
        css = "fa fa-#{name}"
        css += " fa-spin" if options[:spin]
        case :icon_size
          when :large
            css += " fa-lg"
          when :x2
            css += " fa-2x"
          when :x3
            css += " fa-3x"
          when :x4
            css += " fa-4x"
          when :x5
            css += " fa-5x"
        end
        css += " " + options[:class] if options[:class]
        html = get_html_attributes css, options, {
          id: options[:id]
        }
        template.content_tag :i, "", html
      end

    end
  end
end