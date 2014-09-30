module BootstrapHelpers
  module Builders
    class Dropdown < Base
      

      def initialize template, options = {}, &block
        @source = options[:source]
        super template, options, &block

        header { options[:header] }
      end

      def header options = {}, &header_block
        fail 'Header Block required.' unless header_block
        html = get_html_attributes 'dropdown-toggle', options, {
          id: options[:id],
          type: 'button', :'data-toggle' => 'dropdown'
        }
        @header_html = template.content_tag(:a, template.capture(self, &header_block), html)
      end

      def item_template options = {}, &template_block
        fail 'Block required.' unless template_block
        @template_block = template_block
      end

      def render
        capture_content

        fail 'Item template required.' unless @template_block
        html = get_html_attributes 'btn-group', options, {
          id: options[:id]
        }
        template.content_tag(:div, html) do
          out = @header_html
          out << template.content_tag(:ul, role: 'menu', :'class' => 'dropdown-menu') do
            out2 = ActiveSupport::SafeBuffer.new
            @source.each do |item|
              out2 << template.content_tag(:li) do
                template.capture(item, &@template_block)
              end
            end
            out2
          end
          out
        end
      end

    end
  end
end