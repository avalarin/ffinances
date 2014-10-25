module BootstrapHelpers
  module Builders
    class Link < Base

      def render
        options[:style] ||= :default

        content = options[:text] || capture_content

        if (options[:icon])
          icon_html = template.capture do
            template.bt_icon options[:icon]
          end
          content = icon_html + " " + content
        end

        css = Link.get_link_class options
        html = get_html_attributes css, options, {
          id: options[:id],
          title: options[:title],
          href: options[:href]
        }
        html[:title] ||= options[:text]
        
        template.content_tag :a, content, html
      end

      def self.get_link_class options
        css = "link"
        css << " " << Link.get_link_style_class(options[:style])
        css << " " << Link.get_link_size_class(options[:size])
        css
      end

      def self.get_link_style_class style
        "link-#{ style }"
      end

      def self.get_link_size_class size
        case size
          when :large
            "link-lg"
          when :small
            "link-sm"
          when :xsmall
            "link-xs"
          else
            ""
        end
      end

    end
  end
end