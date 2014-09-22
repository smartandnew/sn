module AdminHelper

  def sign_in(admin)
    cookies.permanent.signed[:remember_token] = [admin.id, admin.salt]
    self.current_admin = admin
  end

  def current_admin=(admin)
    @current_admin = admin
  end



  #def current_user
  # @current_user ||= user_from_remember_token
  #end


  def current_admin
    @current_admin ||= lookup_admin
  end

  def lookup_admin
    if cookies[:auth_token]
      Admin.find_by_auth_token!(cookies[:auth_token])
    elsif session[:admin_id]
      Admin.find_by_id(session[:admin_id])
    end
  end

  def go_index_if_signed_in
    if admin_is_signed_in?
      redirect_to admin_index_path
    end
  end


  def admin_is_signed_in?
    !current_admin.nil?
  end

  def sign_out_admin
    cookies.delete(:remember_token)
    self.current_admin = nil
  end

  # def current_admin(admin)
  #   admin == current_admin
  # end

  def authenticate_admin
    if !admin_is_signed_in?
      raise ActionController::RoutingError.new('Not Found')
    end
    # deny_access if  !admin_is_signed_in?
  end

  def deny_access
    store_location
    if user_is_signed_in?
      redirect_to profile_path
    else
      redirect_to root_url
    end

  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private

  def admin_from_remember_token
    Admin.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end
end
