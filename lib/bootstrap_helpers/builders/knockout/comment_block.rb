module BootstrapHelpers
  module Builders::Knockout
    class CommentBlock < ::BootstrapHelpers::Builders::Base
      
      def render
        params = options[:params]
        template.raw "<!-- ko #{params} -->\n#{capture_content}\n<!-- /ko -->"
      end

    end
  end
end