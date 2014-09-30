module BootstrapHelpers
  module Builders::Knockout
    class Template < ::BootstrapHelpers::Builders::Base
      
      def render
        name = options[:name]
        template.content_tag(:script, capture_content, type: 'text/html', id: name)
      end

    end
  end
end