module UserProfileHelper

  def avatar_image user, options = {}
    css = 'avatar '
    case options[:size]
    when :large
      css << 's64'
    when :medium
      css << 's24'
    when :small
      css << 's18'
    end

    html = get_html_attributes css, options, {
      id: options[:id],
      src: user.avatar.url(options[:size] || :large)
    }

    content_tag :img, '', html
  end

  def user_profile_link user, options = {}
    html = get_html_attributes 'user-profile-link', options, {
      id: options[:id],
      href: '#'
    }
    content_tag :a, html do
      out = ActiveSupport::SafeBuffer.new
      out << avatar_image(user, size: options[:avatar]) if options[:avatar]
      out << content_tag(:span, user.display_name)
    end
  end


end