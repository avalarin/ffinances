module SessionHelper

  def get_book_role_index role
    case role
    when :owner
      20
    when :admin
      15
    when :master
      10
    when :readonly
      5
    else
      0
    end
  end

  def current_session
    session_key = cookies['session']
    return nil if !session_key

    s = Session.find_by_key(session_key)
    return nil if !s || s.closed || DateTime.now > s.expires_at;
    s
  end

  def current_user
    s = current_session;
    return nil if !s 
    s.user
  end

  def current_book
    key = session[:current_book]
    return nil unless key
    return Book.find_by_key(key)
  end

  def set_current_book book
    raise ArgumentError, 'book required' unless book
    session[:current_book] = book.key
  end

  def current_book_role
    book = current_book
    user = current_user
    return nil unless book && user
    return book.get_role(user)
  end

  def authenticated?
    return false if !current_user
    true
  end

  def login_user(user, persistence, client)
    s = Session.new
    s.key = SecureRandom.uuid
    s.user = user;
    s.persistent = persistence
    s.ip = client[:ip]
    s.user_agent = client[:user_agent]
    lifetime = persistence ? Settings.security.persistent_session_lifetime : Settings.security.session_lifetime
    s.expires_at = DateTime.now + lifetime
    s.save!

    cookies['session'] = {   
        value: s.key,
        expires: persistence ? s.expires_at : nil,
        httponly: true
    }
  end

  def logout_user
    return if !current_session

    s = Session.find_by_key(current_session.key)
    s.closed = true
    s.closed_at = DateTime.now
    s.save!

    cookies.delete 'session'
  end 

  def has_book_role role
    role_index = get_book_role_index role
    user_role_index = get_book_role_index current_book_role
    return role_index <= user_role_index
  end

end