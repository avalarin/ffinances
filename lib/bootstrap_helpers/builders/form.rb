module BootstrapHelpers
  module Builders
    class Form < Base

      def initialize template, options = {}, &block
        initialize_model options
        super template, options, &block
      end

      def render
        method = options[:method] || :post
        original_method = method
        if (method != :get && method != :post)
          method = :post;
        end
        options[:style] ||= :default
        case options[:style]
        when :horizontal
          css = 'form-horizontal '
        else
          css = ''
        end

        html = get_html_attributes css, options, {
          id: options[:id],
          action: options[:action],
          method: method
        }

        pre_content = template.content_tag :input, '', {
          type: 'hidden',
          value: template.form_authenticity_token,
          name: 'authenticity_token'
        }
        pre_content << template.content_tag(:input, '', {
          type: 'hidden',
          value: original_method,
          name: '_method'
        })

        template.content_tag :form, pre_content + capture_content, html
      end

      def group options = {}, &block
        builder = FormGroup.new template, self.options.merge(options), &block
        builder.render
      end

      def static options = {}, &block
        property_name = options[:property] || @property_name
        
        css = 'form-control-static'
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name)
        }
        if block
          template.content_tag :p, html do
            block.call
          end
        else
          value = model.respond_to?(property_name) ? model.send(property_name) : ''
          template.content_tag :p, value, html
        end
      end

      def text_input options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ''
        css = get_text_input_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          value: options[:value] || value,
          type: 'text'
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, '', html
      end

      def hidden_input options = {} 
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ''
        html = get_html_attributes '', options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          value: options[:value] || value,
          type: 'hidden'
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, '', html
      end

      def password_input options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ''
        css = get_text_input_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          value: options[:value] || value,
          type: 'password'
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, '', html
      end

      def checkbox options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : nil
        html = get_html_attributes '', options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          value: 'true',
          type: 'checkbox'
        }
        html[:checked] = 'checked' if (value)
        html.merge! validation_attributes(property_name)

        template.content_tag :label, class: 'checkbox' do
          # out = template.content_tag(:input, '', {type: 'hidden', name: html[:name], value: 'false'})
          out = hidden_input property: property_name, value: 'false'
          out << template.content_tag(:input, '', html)
          out << ' ' + options[:text]
          out
        end
      end

      def captcha captcha, options = {}
        html = get_html_attributes 'captcha', options, { }
        value_input_html = get_html_attributes 'form-control captcha-value', options[:value_input] || { }, {
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          name: 'captcha[value]',
          type: 'text',
          :'data-val' => 'true',
          :'data-val-required' => I18n.t('errors.messages.blank')
        }
        code_input_html = get_html_attributes 'form-control captcha-code', options[:code_input] || { }, {
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          name: 'captcha[code]',
          type: 'hidden',
          value: captcha.code
        }
        template.content_tag :div, html do
          html = template.content_tag(:img, '', { src: captcha.url, :class => "img-thumbnail" })
          html << template.content_tag(:div, '', {}) do
            html2 = template.content_tag(:input, '', code_input_html)
            html2 << template.content_tag(:span, I18n.t('messages.enter_captcha'), { :'class' => 'help-block' })
            html2 << template.content_tag(:input, '', value_input_html)
          end
        end
      end

      def text_area options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ''
        css = get_text_input_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder || generate_label(property_name),
          value: options[:value] || value
        }
        html.merge! validation_attributes(property_name)
        template.content_tag :textarea, '', html
      end

      def select options = {}
        property_name = options[:property] || @property_name
        source = options[:source] || []
        value_property_name = options[:value_property] || :id
        text_property_name = options[:text_property] || :to_s
        value = model.respond_to?(property_name) ? model.send(property_name) : ''
        css = get_text_input_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name)
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :select, html do
          out = ActiveSupport::SafeBuffer.new
          source.each do |item|
            item_value = item.send(value_property_name)
            item_text = item.send(text_property_name)
            item_html = { value: item_value }
            item_html[:selected] = "selected" if item_value == value
            out << template.content_tag(:option, item_text, item_html)
          end
          out
        end
      end

      def submit_button options = {}
        property_name = options[:property] || @property_name
        options[:style] ||= :success
        css = Button.get_button_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          type: 'submit'
        }
        template.content_tag :button, options[:text], html
      end

      protected

      def initialize_model options
        raise ArgumentError, 'Option required: record' unless options[:record]
        case options[:record]
          when String, Symbol
            @model_name = options[:record]
            @model_class = Kernel.const_get(options[:record].capitalize)
            @model = @model_class.new
          else
            @model = options[:record].is_a?(Array) ? options[:record].last : options[:record]
            @model_name  = options[:as] || @model.class.model_name.param_key
            @model_class = @model.class
        end
      end

      def validation_attributes property
        attrs = { :'data-val' => 'true' }
        errors = ActiveModel::Errors.new model
        model_class.validators.each do |validator| 
          next unless validator.attributes.include? property
          validator_options = {}
          validator.options.each_pair { |k, v| validator_options[k] = v }
          case validator
          when ActiveModel::Validations::PresenceValidator
            attrs[:'data-val-required'] = errors.generate_message(property, :blank)
          when ActiveModel::Validations::LengthValidator
            # if validator_options.has_key? :is
            #   attrs[:'data-val-is'] = errors.generate_message(property, :wrong_length)
            # end
            if validator_options.has_key?(:minimum) && validator_options.has_key?(:maximum)
              attrs[:'data-val-length'] = errors.generate_message(property, :too_short_or_too_long_no_count, validator_options)
              attrs[:'data-val-length-min'] = validator_options[:minimum]
              attrs[:'data-val-length-max'] = validator_options[:maximum]
            elsif validator_options.has_key? :minimum
              attrs[:'data-val-length'] = errors.generate_message(property, :too_short_no_count, validator_options)
              attrs[:'data-val-length-min'] = validator_options[:minimum]
            elsif validator_options.has_key? :maximum
              attrs[:'data-val-length'] = errors.generate_message(property, :too_long_no_count, validator_options)
              attrs[:'data-val-length-min'] = validator_options[:minimum]
              attrs[:'data-val-length-max'] = validator_options[:maximum]
            end
          # when EmailFormatValidator
          #   attrs[:'data-val-regex'] = errors.generate_message(property, :invalid_email_address)
          #   attrs[:'data-val-regex-pattern'] = '^[^@]+@[^@]+$'
          when ActiveModel::Validations::ConfirmationValidator
            other = property.to_s + '_confirmation'
            attrs[:'data-val-equalto'] = errors.generate_message(property, other.to_sym)
            attrs[:'data-val-equalto-other'] = generate_full_name other
          end
        end
        attrs
      end

      def model
        @model
      end

      def model_name
        @model_name
      end

      def model_class
        @model_class
      end

      def generate_element_id property_name
        return '' if property_name == '' || !property_name
        model_name.to_s + '_' + property_name.to_s
      end

      def generate_full_name property_name
        return '' if property_name == '' || !property_name
        model_name.to_s + '[' + property_name.to_s + ']'
      end

      def generate_label property_name
        return '' if property_name == '' || !property_name
        return I18n.t("model.#{model_name}.#{property_name}")
      end

      def get_text_input_class options
        css = 'form-control'

        case options[:size]
        when :large
          css << ' input-lg'
        when :small
          css << ' input-sm'
        end
        css
      end

    end

    class FormGroup < Form

      def initialize template, options = {}, &block
        initialize_model options

        if (options[:label_col_size] && options[:controls_col_size])
          @label_col_size = options[:label_col_size] || 3
          @control_col_size = options[:controls_col_size] || 12
        elsif options[:label_col_size]
          @label_col_size = options[:label_col_size]
          @control_col_size = 12 - @label_col_size
        elsif options[:controls_col_size]
          @control_col_size = options[:controls_col_size]
          @label_col_size = 12 - @control_col_size
        else
          @label_col_size = 3
          @control_col_size = 9
        end
                
        @property_name = options[:property] || ''
        @element_name = options[:input_name] || generate_full_name(@property_name)
        @element_id = options[:input_id] || generate_element_id(@property_name)
        @element_placeholder = options[:label] || generate_label(@property_name)

        if (options[:label] == false)
          @label = nil
        else
          @label = options[:label] || generate_label(@property_name)
        end

        super template, options, &block
      end

      def render
        label_size = @label_col_size
        ctrl_size = @control_col_size
        content = capture_content
        
        template.capture do
          if options[:style] == :horizontal
            label_class = "col-sm-#{label_size} "
            ctrl_class = "col-sm-#{ctrl_size} "
          else
            label_class = ''
            ctrl_class = ''
          end
          if @label
            template.content_tag(:div, class: 'form-group') do
              html = template.content_tag(:label, @label, class: label_class + 'control-label', for: @element_id)
              html << template.content_tag(:div, content, class: ctrl_class)
              html
            end
          else
            template.content_tag(:div, class: "form-group") do
              content
            end
          end
        end
      end

    end

  end
end