class SessionController < ApplicationController
  include SessionHelper
  before_filter :go_profile_if_signed_in , :only => [:create ,:new]
  def new
    @user=User.new
  end

  def create

    user = User.authenticate(user_params[:username],user_params[:password])
    if user
      session[:user_id] = user.id
      session[:parent_id] = user.id
      session[:user_name] = user.username
      redirect_to profile_path
    else
      flash.now[:error]="Invalid username or password"
      render 'new'
    end

  end

  def destroy
    session[:user_id] = nil
    session[:parent_id] = nil
    sign_out_user
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end
