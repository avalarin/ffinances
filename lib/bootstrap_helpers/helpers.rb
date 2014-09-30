require File.expand_path('../builders/modal.rb', __FILE__)
require File.expand_path('../builders/panel.rb', __FILE__)

module BootstrapHelpers
  module Helpers
    def bt_modal(options = {}, &block)
      builder = ::BootstrapHelpers::Builders::Modal.new(self, options, &block)
      builder.render
    end

    def bt_panel options = {}, &block
      builder = ::BootstrapHelpers::Builders::Panel.new(self, options, &block)
      builder.render
    end

    def bt_toolbar options = {}, &block
      builder = ::BootstrapHelpers::Builders::Toolbar.new(self, options, &block)
      builder.render
    end

    def bt_button options = {}, &block
      builder = ::BootstrapHelpers::Builders::Button.new(self, options, &block)
      builder.render
    end

    def bt_icon name, options = {}, &block
      options[:name] = name
      builder = ::BootstrapHelpers::Builders::Icon.new(self, options, &block)
      builder.render
    end

    def bt_form_for record, options = {}, &block
      options[:record] = record
      builder = ::BootstrapHelpers::Builders::Form.new(self, options, &block)
      builder.render
    end

    def bt_label text, options = {}, &block
      options[:text] = text
      builder = ::BootstrapHelpers::Builders::Label.new(self, options, &block)
      builder.render
    end

    def bt_pills options = {}, &block
      builder = ::BootstrapHelpers::Builders::Pills.new(self, options, &block)
      builder.render
    end

    def bt_dropdown options = {}, &block
      builder = ::BootstrapHelpers::Builders::Dropdown.new(self, options, &block)
      builder.render
    end

    def ko params, options = {}, &block
      options[:params] = params
      builder = ::BootstrapHelpers::Builders::Knockout::CommentBlock.new(self, options, &block)
      builder.render
    end

    def ko_template name, options = {}, &block
      options[:name] = name
      builder = ::BootstrapHelpers::Builders::Knockout::Template.new(self, options, &block)
      builder.render
    end

  end
end