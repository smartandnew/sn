module SessionHelper
  include AdminHelper

  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  # def go_home_if_user_signed_in
  #   if user_is_signed_in?
  #     redirect_to home_index_path
  #   end
  # end
  #def current_user
  # @current_user ||= user_from_remember_token
  #end


  def current_user
    @current_user ||= lookup_user
  end

  def lookup_user
    if cookies[:auth_token]
      User.find_by_auth_token!(cookies[:auth_token])
    elsif session[:user_id]
      User.find_by_id(session[:user_id])
    end
  end

  def go_profile_if_signed_in
    if user_is_signed_in?
      redirect_to profile_path
    else
      if admin_is_signed_in?
        redirect_to admin_index_path
      end
    end
  end


  def user_is_signed_in?
    !current_user.nil?
  end

  def sign_out_user
    session[:user_id]=nil
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def current_user?(user)
    user == current_user
  end

  def authenticate
    deny_access unless user_is_signed_in?
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

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
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
