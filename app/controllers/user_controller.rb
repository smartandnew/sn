require 'securerandom'

class UserController < ApplicationController
  include SessionHelper
  before_filter :go_profile_if_signed_in, :except => [:edit_info, :update_user_info, :change_password, :update_password, :expenses, :update_governorates, :update_regions]

  def sign_up
    session.delete(:first_product)
    session.delete(:user)
    session.delete(:user_info)
    session.delete(:tree)
    session.delete(:email_verify_code)
    calculation=Calculation.first
    @products=Product.where("price >=? and quantity>0",
                            calculation.minimum_product_price)
  end

  def forget_password
  end

  # send new password to the entered email for the user .
  def send_new_password
    email= email_reset_params["email"]
    user_info=UserInfo.find_by_email(email)
    if user_info
      user=User.find(user_info.user_id)
      password= SecureRandom.urlsafe_base64(8)
      user.update_attribute(:new_password, password)
      UserMailer.reset_password(email, user.username, password).deliver
      redirect_to signin_path
    else
      flash.now[:error]="E-mail not found"
      render :action => 'forget_password'
    end

  end

  # show the sign up form page for the user .
  def new_signup
    @countries = Country.all
    @governorates = Governorate.where("country_id = ?", Country.first.id)
    @regions = Region.where("governorate_id = ?", @governorates[0].id)
    calculations=Calculation.first
    begin
      product=Product.find(String(session[:first_product]).to_i)
    rescue
      session[:first_product]=nil
      redirect_to signUp_path
      return
    end
    if session[:first_product] == nil || product.price<calculations.minimum_product_price
      session[:first_product]=nil
      redirect_to signUp_path
    else

      if session[:user_id]==nil
        @user = User.new
      else
        @user=User.new(session[:user])
      end
      if session[:user_info]==nil
        @user_info=@user.build_user_info
      else
        @user_info=UserInfo.new(session[:user_info])
      end
      @country=Country.new
      @governorate=Governorate.new
      @region=Region.new
    end
  end

  def update_governorates
    @governorates = Governorate.where("country_id = ?", params[:country_id])
    @regions = Region.where("governorate_id = ?", @governorates[0].id)
    respond_to do |format|
      format.js
    end
  end

  def update_regions
    @regions = Region.where("governorate_id = ?", params[:governorate_id])
    respond_to do |format|
      format.js
    end
  end

  def select_first_product
    session[:first_product] = params[:product_id]
    @selected_first_product = Product.find_by_id(session[:first_product])
    if @selected_first_product && @selected_first_product.quantity >0
      # redirect_to signUp_path

      new_signup
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    else
      flash.now[:error]= "This product is not available now"
      render 'first_product'
    end
  end

  #create new user into database .
  def create
    remove_spaces_from_number_fields(user_info_params)
    @user=User.new(user_params)
    @user.master_credit=0
    @user.product_credit=0
    @user_info=UserInfo.new(user_info_params)
    @user.code_id=1
    parent=leader_params["leader_id"]
    user_tree=User.find_by_username(parent)
    tree=nil
    if user_tree!=nil
      tree=Tree.find_by_id(user_tree.id)
    end
    if user_tree!=nil&& tree!=nil
      if @user.password==@user.password_confirmation
        if @user.valid?
          @country=@user_info.region.governorate.country
          @governorate=@user_info.region.governorate
          @region=@user_info.region
          @user_info.user_id=0
          if @user_info.valid?
            session[:user]=user_params
            session[:user_info]=@user_info.attributes
            session[:tree]=tree.attributes
            @email_verify_code=Random.rand(10000...99999)
            session[:email_verify_code]=@email_verify_code
            Thread.new do
              UserMailer.signUp(@user_info.email, @email_verify_code).deliver
            end
            @check=true
            respond_to do |format|
              format.html
              format.js
              format.json
            end
          else
            # flash.now[:error]="user information not save:#{@user_info.errors.full_messages}"
            @countries = Country.all
            @governorates = Governorate.where("country_id = ?", Country.first.id)
            @regions = Region.where("governorate_id = ?", @governorates[0].id)

            @check=false
            respond_to do |format|
              format.html
              format.js
              format.json
            end
          end
        else
          @countries = Country.all
          @governorates = Governorate.where("country_id = ?", Country.first.id)
          @regions = Region.where("governorate_id = ?", @governorates[0].id)

          @check=false
          respond_to do |format|
            format.html
            format.js
            format.json
          end
        end
      else
        flash.now[:error]=" passowd and password confirmation not match"
        @countries = Country.all
        @governorates = Governorate.where("country_id = ?", Country.first.id)
        @regions = Region.where("governorate_id = ?", @governorates[0].id)

        @check=false
        respond_to do |format|
          format.html
          format.js
          format.json
        end
      end
    else
      flash.now[:error]="Leader not found"
      @countries = Country.all
      @governorates = Governorate.where("country_id = ?", Country.first.id)
      @regions = Region.where("governorate_id = ?", @governorates[0].id)

      @check=false
      respond_to do |format|
        format.html
        format.js
        format.json
      end
      return
    end
  end

  #verify that the enterd email is the same one in the sign up form .
  @@mutex=Mutex.new

  def verify_email_create
    email_verify_code=email_code_params["code"]
    @code_found=Code.find_by_code(code_params["code"])
    @@mutex.synchronize do
      if @code_found!=nil &&@code_found.valid==true &&@code_found.expired_date>=Date.today
        if email_verify_code.to_i==session[:email_verify_code].to_i
          complete_signup(@code_found)
        else
          flash.now[:error]="Email verification code is invalid "
          @check=0
          respond_to do |format|
            format.html
            format.js
            format.json
          end
        end
      else
        flash.now[:error]="Invalid payed Code "
        @check=0
        respond_to do |format|
          format.html
          format.js
          format.json
        end
      end
    end
  end

  # complete signup and add user to database
  def complete_signup(code_found)
    calculation=Calculation.first
    user=User.new(session[:user])
    user_info=UserInfo.new(session[:user_info])
    tree=Tree.new(session[:tree])
    session.delete(:tree)
    session.delete(:email_verify_code)
    user.code_id=code_found.id

    @selected_first_product = Product.find_by_id(session[:first_product])
    puts "first product quantity:#{@selected_first_product.quantity.to_i}"

    if @selected_first_product.quantity.to_i<=0
      puts "quantity<=0"
      calculation=Calculation.first
      @products=Product.where("price >=? and quantity>0",
                              calculation.minimum_product_price)
      flash.now[:error]="Sorry! product you hava select is just finished now, please select anather one"
      @check=2
      respond_to do |format|
        format.html
        format.js
        format.json
      end
      return
    end
    user.master_credit=0
    user.product_credit=0
    if user.save
      user_info.user_id=user.id
      if user_info.save
        user.update_attribute(:code_id, code_found.id)
        code_found.update_attribute(:valid, false)
        Tree.create!(:id => user.id, :user_id => user.id, :parent => tree.id, :left => 0, :right => 0, :virtual_right_count => 0, :virtual_left_count => 0, :total_left => 0, :total_right => 0, :virtual_credit => 0, :level => 1, :total_cheque_count => 0)
        FirstProduct.create!(:price => @selected_first_product.price, :date_of_price => Date.new,
                             :is_completed => false, :is_delivered => false, :user_id => user.id, :product_id => @selected_first_product.id)
        @selected_first_product.quantity=@selected_first_product.quantity-1
        amount=calculation.code_value-calculation.first_year
        user_master_credit = amount - @selected_first_product.price
        user.update_attribute(:master_credit, user_master_credit)

        session.delete(:first_product)
        session.delete(:user)
        session.delete(:user_info)
        session.delete(:tree)
        session.delete(:email_verify_code)

        user = User.authenticate(user.username, user.password)
        if user
          session[:user_id] = user.id
          session[:parent_id] = user.id
          render :js => "window.location='#{profile_path}'"
        end
      else
        User.delete(user.id)
        new_signup
        flash.now[:error]="user info not save #{user_info.errors.full_messages.first}"
        @check=1
        respond_to do |format|
          format.html
          format.js
          format.json
        end
      end
    else
      new_signup
      flash.now[:error]="user not save #{user.errors.full_messages.first}"
      @check=1
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end

  end

  #show the edit info page for the user to allow him edit his information .
  def edit_info
    if !user_is_signed_in?
      redirect_to root_path
      return
    end
    @current_user=User.find(session[:user_id])
    @updated_user_info=UserInfo.find_by_user_id(@current_user.id)
    @countries = Country.all
    @governorates = Governorate.where("country_id = ?", Country.first.id)
    @regions = Region.where("governorate_id = ?", @governorates[0].id)
  end

  # update user info
  def update_user_info
      @current_user=User.find(session[:user_id])
    if @current_user
      @updated_user_info=UserInfo.find_by_user_id(@current_user.id)
      remove_spaces_from_number_fields(updated_user_info_params)
      if @updated_user_info.update_attributes(updated_user_info_params)
        flash[:success]="Information  updated successfully "
        redirect_to profile_path
      else
        @countries = Country.all
        @governorates = Governorate.where("country_id = ?", Country.first.id)
        @regions = Region.where("governorate_id = ?", @governorates[0].id)
        render 'edit_info'
      end
    else
      session[:user_id] = nil
      sign_out_user
      redirect_to root_url
    end
  end

  def remove_spaces_from_number_fields(params)
    mobile=String(params[:mobile]).strip.to_i
    params[:mobile]=mobile
    land_phone=String(params[:land_phone]).strip.to_i
    params[:land_phone]=land_phone
    national_id=String(params[:national_id]).strip.to_i
    params[:national_id]=national_id
    postal_code=String(params[:postal_code]).strip.to_i
    params[:postal_code]=postal_code
  end

  #show change password page to allow the user change his password .
  def change_password
    if !user_is_signed_in?
      redirect_to root_path
      return
    end
    @updated_user=User.find(session[:user_id])
    if @updated_user
    else
      redirect_to root_path
    end
  end

  # udpate user's password in database
  def update_password
    @updated_user=User.find(session[:user_id])
    if @updated_user
      old_password= updated_user_params[:password]
      new_password=updated_user_params[:new_password]
      new_password_confirmation=updated_user_params[:password_confirmation]
      if passwords_are_vlalid(old_password, new_password, new_password_confirmation)
        @updated_user=User.authenticate(@updated_user.username, old_password)
        if @updated_user
          #@updated_user.password=new_password
          if @updated_user.update_attributes(updated_user_params)
            session[:user_id] = nil
            sign_out_user
            flash.now[:success]="password  updated successfully "
            redirect_to root_url
          else
            flash.now[:error]="error , could not save object"
            render :action => 'change_password'
          end
        else
          @updated_user=User.find(session[:user_id])
          flash.now[:error]=" The password you entered is not valid"
          render :action => 'change_password'
        end
      else
        return
      end

    else
      session[:user_id] = nil
      sign_out_user
      redirect_to root_url
    end
  end

  # ensure that user entered new password and new password confirmation .
  def passwords_are_vlalid(old_password, new_password, new_password_confirmation)
    if (old_password.empty?) || (new_password.empty?) || (new_password_confirmation.empty?)
      flash.now[:error]="Required field can't be blank "
      render :action => 'change_password'
      return false
    elsif old_password==new_password
      flash.now[:error]="New password can't be the same old password "
      render :action => 'change_password'
      return false
    elsif (new_password.mb_chars.length <6)
      flash.now[:error]="New password must be at least 6 characters "
      render :action => 'change_password'
      return false
    elsif new_password!=new_password_confirmation
      flash.now[:error]="new_password and new_password_confirmation don't match "
      render :action => 'change_password'
      return false
    else
      return true
    end
  end

  #
  def validates_old_password(old_password)
    if old_password.
        flash.now[:error]="Password can't be blank"
      render 'change_password'
      return true
    else
      return false
    end
  end

  def validates_new_password(new_password)
    if new_password==""
      flash.now[:error]="New password can't be blank"
      render 'change_password'
      return true
    else
      return false
    end
  end

  def validates_new_password_confiramtion(new_password_confirmation)
    if new_password_confirmation==""
      flash.now[:error]="Password confirmation can't be balnk"
      render 'change_password'
      return true
    else
      return false
    end
  end

  def match_password(password, password_cofirmation)
    return (password==password_cofirmation) ? true : false
  end

  def expenses

    if user_is_signed_in?
      @codes = Expense.where("(code_id is not null) and user_id =?", current_user.id)
      # @renew = Expense.where("is_master = ? and code_id=? and sale_id=? and user_id =?",true,"","",current_user.id)
      @renew=Expense.where("is_master=? and is_money=? and ((code_id is null) or (code_id='')) and ((sale_id is null) or (sale_id=''))  and user_id=?", true, false, current_user.id)

      #show_first_product
      @first_product_info= FirstProduct.find_by_user_id(current_user.id)
      if @first_product_info
        @first_product=Product.find(@first_product_info.product_id)
        if File.exist?("app/assets/images/data/products/#{@first_product.id}")
          @product_images=Dir.glob("app/assets/images/data/products/#{@first_product.id}/*").map do |f|
            File.basename f
          end.sort
          # @selected_product_images.sort
        end
      end

      #show user sales
      @user_expenses_sales=Expense.where("(sale_id is not null) and user_id=?", current_user.id)
    else
      redirect_to root_path
    end

  end

  def show_sales

  end

  private

  def user_credit_params
    params.require(:user).permit(:master_credit, :product_credit)
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def user_info_params
    params.require(:user_info).permit(:first_name, :last_name, :email, :mobile, :land_phone, :address1, :address2, :postal_code, :national_id, :gender, :birthdate, :status_id, :region_id, :governorate_id, :country_id)
  end

  def updated_user_params
    params.require(:user).permit(:password, :new_password, :password_confirmation)
  end

  def updated_user_info_params
    params.require(:user_info).permit(:first_name, :last_name, :mobile, :address1, :address2, :postal_code, :gender, :national_id, :birthdate, :status_id, :region_id, :governorate_id, :country_id)
  end

  def country_params
    params.require(:county).permit(:id, :name)
  end

  def governorate_params
    params.require(:county).permit(:id, :name, :country_id)
  end

  def region_params
    params.require(:county).permit(:id, :name, :governorate_id)
  end

  def leader_params
    params.require(:leader).permit(:leader_id)
  end

  def code_params
    params.require(:code).permit(:code)
  end

  def email_code_params
    params.require(:email_code).permit(:code)
  end

  def email_reset_params
    params.require(:email).permit(:email)
  end

end
