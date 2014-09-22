class AdminController < ApplicationController
  include AdminHelper
  include SessionHelper
  before_filter :authenticate_admin, :except => [:login, :admin_login]

  # before_filter :empty_searched_admin_id, :except => [:update_sub_admin]
  # show login page for non logged in admin or show admin_index page if admin is logged in
  def login
    if admin_is_signed_in?
      redirect_to admin_index_path
      return
    end
    if user_is_signed_in?
      redirect_to root_path
      return
    end
    @admin=Admin.new
  end

  # used by admin to login to system .
  def admin_login
    if user_is_signed_in?
      redirect_to root_path
      return
    end
    admin = Admin.authenticate(admin_params[:username], admin_params[:password])
    if admin
      session[:admin_id] = admin.id
      session[:admin_name] = admin.username
      redirect_to admin_index_path
    else
      flash.now[:error]="Invalid username or password "
      render 'login'
    end
  end

  # view new page that allow super admin to create new admin
  def new
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @new_admin=Admin.new
  end


  #used only by super admin to create a new admin
  def create
    mobile=String(admin_params[:mobile]).strip.to_i
    admin_params[:mobile]=mobile
    @new_admin=Admin.new(admin_params)
    password=admin_params[:password]
    password_confirmation=admin_params[:password_confirmation]
    if match_password(password, password_confirmation)
      @new_admin.is_super_admin=false
      if check_privilages_existence(admin_privilages)
        @new_admin.privilages=admin_privilages
        if @new_admin.save
          flash[:success]="admin with username => #{@new_admin.username} successfully created "
          redirect_to admin_index_path
        else
          render 'new'
        end
      else
        render 'new'
      end
    else
      flash.now[:error]="password and password confirmation don't match"
      render 'new'
    end
  end

  # check if the two passwords are equal .
  def match_password(password, password_cofirmation)
    return (password==password_cofirmation) ? true : false
  end

  # used to create privileges of the new created  admin .
  def admin_privilages
    @reset_passwords=(admin_params[:can_reset_password]=="1") ? "1" : "0"
    @generate_codes=(admin_params[:can_generate_code]=="1") ? "2" : "0"
    @add_products=(admin_params[:can_add_product]=="1") ? "3" : "0"
    @add_places=(admin_params[:can_add_place]=="1") ? "4" : "0"
    privilages =@reset_passwords+","+@generate_codes+","+@add_products+","+@add_places
    return privilages
  end

  # ensure that at least there is only one privilage for the new admin
  def check_privilages_existence(privilages)
    if (privilages.include? '1') || (privilages.include? '2') || (privilages.include? '3') || (privilages.include? '4')
      return true
    else
      flash.now[:error]="Please, specify at least one privilage for the new admin "
      return false
    end
  end


  # used to sign out admin
  def destroy
    empty_searched_admin_id
    empty_user_id
    session[:admin_id] = nil
    sign_out_admin
    redirect_to admin_login_path
  end


  # show index page
  def index
    if admin_is_signed_in?
      @admin=current_admin
      @amdin_is_super=(current_admin.is_super_admin) ? true : false
      @admin_can_reset_password= (current_admin.privilages.include? '1') ? true : false
      @admin_can_generate_codes=(current_admin.privilages.include? '2') ? true : false
      @admin_can_add_product=(current_admin.privilages.include? '3') ? true : false
      @admin_can_add_place=(current_admin.privilages.include? '4') ? true : false
    end
  end

  #show admin_actions page for
  def admin_actions
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
  end

  def edit_info
    redirect_to update_super_admin_path
  end

  #show update super_admin page
  def update_super_admin
    unless current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @admin=current_admin
    @admin_=current_admin
  end

  #udpate super  admin  info
  def update_super_admin_info
    @admin=current_admin
    if @admin
      old_password=admin_params[:password]
      @admin=Admin.authenticate(@admin.username, old_password)
      if @admin
        @admin.privilages="empty"
        mobile=String(admin_params[:mobile]).strip.to_i
        admin_params[:mobile]=mobile
        @admin.update_attributes(admin_params)
        if @admin.valid?
          flash[:success]="Updated succesfuly "
          redirect_to admin_index_path
        else
          @admin_=current_admin
          render 'update_super_admin'
        end
      else
        flash.now[:error]="Invalid password"
        @admin=current_admin
        @admin_=current_admin
        render 'update_super_admin'
      end
    else
      redirect_to admin_index_path
    end
  end


  #reset super  admin  password
  def reset_super_admin_password
    @admin_=current_admin
    if @admin_
      old_password=admin_params[:password]
      new_password=admin_params[:new_password]
      new_password_confirmation=admin_params[:password_confirmation]
      if passwords_are_vlalid(new_password, new_password_confirmation, 'update_super_admin')
        @admin_=Admin.authenticate(@admin_.username, old_password)
        if @admin_
          if  @admin_.update_attribute(:new_password, new_password)
            flash[:success]="Updated succesffuly "
            destroy
          else
            flash.now[:error]="Error, couldn't update password"
            @admin=current_admin
            @admin_=current_admin
            render 'update_super_admin'
          end
        else

          flash.now[:error]="Old password is incorrect "
          @admin=current_admin
          @admin_=current_admin
          render 'update_super_admin'
        end

      else
        @view_super_admin_change_password_form=true
        return
      end
    else
      redirect_to admin_index_path
    end
  end

  # only used by super admin to show all sub admins
  def all_sub_admins
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @all_sub_admins=Admin.where("is_super_admin !=?", true).paginate(:page => params[:page], :per_page => 9)
  end

  # used only by super admin to pick an admin from all sub_admin to update his info
  def view_sub_admin
    @sub_admin=Admin.find(params[:sub_admin_id])
    session[:searched_addmin_id]=params[:sub_admin_id]
    session[:updating_using_ajax]=1
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

# show search admin page for super to edit sub admins .
  def search_admins
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @sub_admin=Admin.new
  end

  # empty session of searched admin
  def empty_searched_admin_id
    session[:searched_addmin_id]=nil
  end


  # search admins in database by the entered username .
  def search_admins_by_username
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @searched_admin_username=admin_params[:username]
    if @searched_admin_username.empty?
      flash.now[:error]="Please, enter an username  "
      @sub_admin=Admin.new
      render 'search_admins'
    else
      @sub_admin=Admin.find_by_username(@searched_admin_username)
      if @sub_admin && !@sub_admin.is_super_admin
        session[:searched_addmin_id]=@sub_admin.id
        respond_to do |format|
          format.html
          format.js
          format.json
        end
      else
        flash[:error]="couldn't find admin with username => #{@searched_admin_username} "
        render :js => "window.location='#{search_admins_path}'"
      end
    end
  end

  #show update sub_admin page
  def update_sub_admin
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end

    if  session[:searched_addmin_id]
      @sub_admin=Admin.find(session[:searched_addmin_id])
    else
      redirect_to admin_index_path
    end
  end

  #udpate selected  admin
  def update_sub_admin_info
    if  session[:searched_addmin_id]
      @sub_admin=Admin.find(session[:searched_addmin_id])
      if @sub_admin
        @sub_admin.privilages=admin_privilages
        mobile=String(admin_params[:mobile]).strip.to_i
        admin_params[:mobile]=mobile
        #set password for object to be valid and accept update .
        @sub_admin.password="xxxxxx"
        if admin_privilages && check_privilages_existence(admin_privilages)
          if @sub_admin.update_attributes(admin_params)
            flash[:success]="Updated succesffuly "
            if session[:updating_using_ajax]==1
              render :js => "window.location='#{all_sub_admins_path}'"
              session[:updating_using_ajax]=nil
              else
              render :js => "window.location='#{search_admins_path}'"
            end
          else
            respond_to do |format|
              format.html
              format.js
              format.json
            end
          end
        else

          # @sub_admin.privilages=nil
          respond_to do |format|
            format.html
            format.js
            format.json
          end
        end
      else
        render :js => "window.location='#{admin_index_path}'"
      end
    else
      flash[:error]="error session is empty "
      render :js => "window.location='#{admin_index_path}'"
    end
  end

  #reset sub  admin  password
  def reset_sub_admin_password
    @sub_admin=Admin.find(session[:searched_addmin_id])
    if @sub_admin
      new_password=admin_params[:new_password]
      new_password_confirmation=admin_params[:password_confirmation]
      if passwords_are_vlalid_ajax(new_password, new_password_confirmation)
        if  @sub_admin.update_attribute(:new_password, new_password)
          @show_edit_password=false
          flash[:success]="Updated succesfully "
          render :js => "window.location='#{admin_index_path}'"
          # redirect_to admin_index_path
        else
          @show_edit_password=true
          flash.now[:error]="Invalid fields"
          @sub_admin=Admin.find(session[:searched_addmin_id])
          respond_to do |format|
            format.html
            format.js
            format.json
          end
        end
      else
        @show_edit_password=true
        @sub_admin=Admin.find(session[:searched_addmin_id])
        respond_to do |format|
            format.html
            format.js
            format.json
          end
        return
      end
    else
      redirect_to admin_index_path
    end
  end

  # show search users page for admin who has the authority to edit users .
  def search_users
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '1'
        flash[:authority_error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        empty_user_id
        return
      end
    end
    empty_user_id
    @check=0
    @searched_user=User.new
  end

  # search users in database by the entered username .
  def search_users_by_username
    @check=0
    @username=updated_user_params[:username]
    if @username.empty?
      flash.now[:error]="Please, enter an username "
      @all_searched_users=Array.new
      render 'search_users'
    else
      @all_searched_users=User.where("username like ?", "%"+@username+"%").paginate(:page => params[:page], :per_page => 9)
      if @all_searched_users && !@all_searched_users.empty?
        @searched_user=User.new
        render 'search_users'
      else
        @searched_user=User.new
        @all_searched_users=Array.new
        render 'search_users'
      end
    end
  end

  def view_searched_user
    @searched_user=User.find(params[:searched_user_id])
    session[:user]=params[:searched_user_id]
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def edit_searched_user
    @check=2
    @user_info=UserInfo.find_by_user_id(session[:user])
    @user=User.find(session[:user])
    @countries = Country.all
    @governorates = Governorate.where("country_id = ?", Country.first.id)
    @regions = Region.where("governorate_id = ?", @governorates[0].id)
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def remove_spaces_from_number_fields(user_info_params)
    master_credit=String(user_params[:master_credit]).strip.to_i
    user_params[:master_credit]=master_credit
    product_credit=String(user_params[:product_credit]).strip.to_i
    user_params[:product_credit]=product_credit
    mobile=String(user_info_params[:mobile]).strip.to_i
    user_info_params[:mobile]=mobile
    land_phone=String(user_info_params[:land_phone]).strip.to_i
    user_info_params[:land_phone]=land_phone
    national_id=String(user_info_params[:national_id]).strip.to_i
    user_info_params[:national_id]=national_id
    postal_code=String(user_info_params[:postal_code]).strip.to_i
    user_info_params[:postal_code]=postal_code
  end


  def update_searched_user_info
    @user_info=UserInfo.find_by_user_id(session[:user])
    @user=User.find(session[:user])
    @user.password="xxxxxxx"
    remove_spaces_from_number_fields(user_info_params)
    @user_info.update_attributes(user_info_params)
    @user.update_attributes(user_params)
    if  @user_info.valid? && @user.valid?
      @check=0
      @searched_user=User.find(session[:user])
      flash.now[:success]="Userser data updated successfully"
    else
      @countries = Country.all
      @governorates = Governorate.where("country_id = ?", Country.first.id)
      @regions = Region.where("governorate_id = ?", @governorates[0].id)
      @check=2
    end
    respond_to do |format|
      format.html
      format.js
      format.json
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

# show page to reste password for the selected user .
  def reset_user_password
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '1'
        flash[:error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        empty_user_id
        return
      end
    end
    if session[:user]
      @searched_user = User.find(session[:user])
    else
      redirect_to admin_index_path
    end
  end

# reset the password for a selected user .
  def reset_password
    @searched_user = User.find(session[:user])
    if @searched_user
      new_password=updated_user_params[:new_password]
      new_password_confirmation=updated_user_params[:password_confirmation]
      if passwords_are_vlalid(new_password, new_password_confirmation, 'reset_user_password')
        if @searched_user.update_attribute(:new_password, updated_user_params[:new_password])
          flash[:success]="password  updated successfully "
          empty_user_id
          redirect_to admin_index_path
        else
          flash.now[:error]="error , could not save password"
          render :action => 'reset_user_password'
        end
      else
        return
      end
    else
      flash[:error]=" could not load user "
      redirect_to admin_index_path
    end
  end

# ensure that new password and new password confirmation are valid .
  def passwords_are_vlalid(new_password, new_password_confirmation, page_to_render)
    if (new_password.empty?) || (new_password_confirmation.empty?)
      flash.now[:error]="Passwords fields can't be blank "
      render page_to_render
      return false
    elsif new_password.mb_chars.length <6
      flash.now[:error]="New password must be at least 6 characters"
      render page_to_render
      return false
    elsif new_password!=new_password_confirmation
      flash.now[:error]="Passwords not equal "
      render page_to_render
      return false
    else
      return true
    end
  end
# ensure that new password and new password confirmation are valid .
  def passwords_are_vlalid_ajax(new_password, new_password_confirmation)
    if (new_password.empty?) || (new_password_confirmation.empty?)
      flash.now[:error]="Passwords fields can't be blank "
      # render page_to_render

      return false
    elsif new_password.mb_chars.length <6
      flash.now[:error]="New password must be at least 6 characters"
      # render page_to_render
      return false
    elsif new_password!=new_password_confirmation
      flash.now[:error]="Passwords not equal "
      # render page_to_render
      return false
    else
      return true
    end
  end

# ensure that new password and new password confirmation are valid .
  def passwords_are_vlalid(new_password, new_password_confirmation, page_to_render)

    if (new_password.empty?) || (new_password_confirmation.empty?)
      flash.now[:error]="Passwords fields can't be blank "
      render page_to_render
      return false
    elsif new_password.mb_chars.length <6
      flash.now[:error]="New password must be at least 6 characters"
      render page_to_render
      return false
    elsif new_password!=new_password_confirmation
      flash.now[:error]="Passwords not equal "
      render page_to_render
      return false
    else
      return true
    end
  end


# used by admin if he is authorized to edit users
  def user_expenses
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '1'
        flash.now[:error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        empty_user_id
        return
      end
    end
    if session[:user]
      @searched_user = User.find(session[:user])
      if @searched_user
        @user_codes = Expense.where("(code_id is not null) and user_id =?", @searched_user.id)
        @user_renew = Expense.where("is_master = ? and (code_id is null) and (sale_id is null) and user_id=?", true, @searched_user.id)

        #show_first_product
        @first_product_info= FirstProduct.find_by_user_id(@searched_user.id)
        if @first_product_info
          @first_product=Product.find(@first_product_info.product_id)
          if File.exist?("app/assets/images/data/products/#{@first_product.id}")
            @product_images=Dir.glob("app/assets/images/data/products/#{@first_product.id}/*").map do |f|
              File.basename f
            end.sort
          end
        end

        #show user sales
        @user_expenses_sales=Expense.where("(sale_id is not null) and user_id=?", @searched_user.id)
      end
    else
      redirect_to admin_index_path
    end
  end

# empty session of searched user
  def empty_user_id
    session[:user]=nil
  end


# show first prodcuts completed
  def users_first_products
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '3'
        flash[:error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        return
      end
    end
    @completed_first_products=FirstProduct.where("is_completed='t' and is_delivered='f'")
  end


# used by admin who has the privileges to confirm products delivery .
  def confirm_first_product_deliverd
    first_product_id=params[:first_product_id]
    if first_product_id
      begin
        @first_product=FirstProduct.find(first_product_id)
      rescue
        # @completed_first_products=FirstProduct.where("is_completed='t' and is_delivered='f'")
        #redirect_to users_first_products_path
        respond_to do |format|
          format.html
          format.js
          format.json
        end
      end
      if @first_product
        if @first_product.update_attribute(:is_delivered, true)
          flash.now[:success]="First product with id #{@first_product.id} delivered"
        else
          flash.now[:error]="First product with id #{@first_product.id} failed to delivered"
        end
      end
      @completed_first_products=FirstProduct.where("is_completed='t' and is_delivered='f'")
      #redirect_to users_first_products_path
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

#custmer and user product order
  def confirm_products_order
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '3'
        flash[:error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        return
      end
    end
    @users_sales=Array.new
    @customers_sales=Array.new
    @sales=Sale.where("is_delivered='f'")

    @sales.each do |sale|
      if sale.customer
        @customers_sales.push(sale)
      else
        @users_sales.push(sale)
      end
    end
      puts "user sale count:#{@users_sales.length}"
      puts "customer sale count:#{@customers_sales.length}"
  end

  def confirm_products_order_deliverd
    sale_id=params[:sale_id]
    if sale_id
      @sale=Sale.find(sale_id)
      if @sale
        if @sale.update_attribute(:is_delivered, true)
          flash.now[:success]="Sale is update delivered success"
        else
          flash.now[:error]="Sale is update delivered faild"
        end
      end
      @users_sales=Array.new
    @customers_sales=Array.new
    @sales=Sale.where("is_delivered='f'")
    @sales.each do |sale|
      if sale.customer
        @customers_sales.push(sale)
      else
        @users_sales.push(sale)
      end
    end
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

# show all codes of the logged in user
  def codes
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '2'
        flash[:error]="You are not authorized to navigate to this page "
        redirect_to admin_index_path
        return
      end
    end
    @unused_codes = Code.where("admin_id=? and valid ='t'", current_admin.id);
    @used_codes = Code.where("admin_id=? and valid ='f'", current_admin.id);
  end

# used by any admin who has the previleges to generate codes for users .
  def generate_code
    if Admin.authenticate(session[:admin_name], admin_params[:conf_pass_for_gen_code])
        begin
        code= SecureRandom.base64
        c=Code.find_by(:code => code)
        end while c!=nil
        calcultion=Calculation.first
        cc=Code.create!(:code => code, :date_released => Time.now, :expired_date => (Date.today+3.month),
                      :value => calcultion.code_value, :valid => true, :verify => true, :admin_id => current_admin.id)
        @unused_codes = Code.where("admin_id=? and valid ='t'", current_admin.id);
        @used_codes = Code.where("admin_id=? and valid ='f'", current_admin.id);

        respond_to do |format|
          format.html
          format.js
          format.json
        end
      return
    else

      @unused_codes = Code.where("admin_id=? and valid ='t'", current_admin.id);
      @used_codes = Code.where("admin_id=? and valid ='f'", current_admin.id);
      flash.now[:error] = "Please, enter a valid password"
      respond_to do |format|
        format.html
        format.js
        format.json
      end
      return
    end
    #render 'codes'
    # redirect_to admin_codes_path
  end

# show slider  images only for super admin
  def slider_images
    unless @current_admin.is_super_admin
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
      return
    end
    @slider_image=SliderImage.new
    dir_name="app/assets/images/slider_images"
    if File.exist?(dir_name)
      @slider_images=Dir.glob(dir_name+"/*").map do |f|
        File.basename f
      end.sort
    else
      Dir.mkdir(dir_name)
      @slider_images=Array.new
    end
  end


# this function is used only by super admin to add or update slider images of site
  def update_slider_images
    dir_name="app/assets/images/slider_images"
    @slider_images=Dir.glob(dir_name+"/*").map do |f|
      File.basename f
    end.sort
    begin
      if  slider_images_params[:slider_image_1]
        create_slider_image_file("slider_image_1", slider_images_params[:slider_image_1], 1)
      end
      if slider_images_params &&slider_images_params[:slider_image_2]
        create_slider_image_file("slider_image_2", slider_images_params[:slider_image_2], 2)
      end
      if slider_images_params &&slider_images_params[:slider_image_3]
        create_slider_image_file("slider_image_3", slider_images_params[:slider_image_3], 3)
      end
      if slider_images_params &&slider_images_params[:slider_image_4]
        create_slider_image_file("slider_image_4", slider_images_params[:slider_image_4], 4)
      end
      if slider_images_params && slider_images_params[:slider_image_5]
        create_slider_image_file("slider_image_5", slider_images_params[:slider_image_5], 5)
      end
      redirect_to slider_images_path
    rescue
      redirect_to slider_images_path
    end
  end


# this method is used to create new file image at the server  for the uploaded image
  def create_slider_image_file(image_name, uploaded_image_parameter, index_of_image)
    directory_name = "app/assets/images/slider_images"
    extention = File.extname(uploaded_image_parameter.original_filename)
    lower_case_extention=extention.downcase
    if lower_case_extention==".jpg" || lower_case_extention ==".jpeg"|| lower_case_extention==".png"|| lower_case_extention==".gif"
      name=image_name+extention
      # create the file path
      path = File.join(directory_name, name)
      # delete old file if exist

      if @slider_images && @slider_images[index_of_image-1]
        File.delete(directory_name+"/#{@slider_images[index_of_image-1]}")
      end
      # write the file
      File.open(path, "wb") { |f| f.write(uploaded_image_parameter.read) }
    else
      flash.now[:error]="Please, select an jpeg,jpg,png or gif file only "
      return
    end

  end

# this method is used only by super admin to view data in the calculations table in database .
  def calculations
    if current_admin.is_super_admin
      begin
        @site_calculations=Calculation.first
      rescue
        flash[:error]="Calculations table is empty "
        redirect_to admin_index_path
      end
    else
      flash[:error]="You are not authorized to navigate to this page "
      redirect_to admin_index_path
    end
  end


# this method is used only by super admin to update and only update the calculations table in database .
  def update_calculations
    @site_calculations=Calculation.first
    begin
      @site_calculations.update_attributes(calculation_params)
      if @site_calculations.valid?
        flash[:success]="Calculations updated  successfully "
        redirect_to admin_index_path
      else
        render 'calculations'
      end
    rescue
      flash[:error]="required fields can't be blank "
      redirect_to calculations_path
    end
  end


  private
  def admin_params
    params.require(:admin).permit(:username, :password, :new_password, :password_confirmation, :first_name, :last_name, :email, :mobile, :address, :privilages, :can_reset_password, :can_generate_code, :can_add_product, :can_add_place, :conf_pass_for_gen_code)
  end

# def super_admin_params
#   params.require(:admin).permit(:username, :password, :first_name, :last_name, :email, :mobile, :address, :privilages, :can_reset_password, :can_generate_code, :can_add_product, :can_add_place)
# end
  def sub_admin_params
    params.require(:admin).permit(:username, :first_name, :last_name, :email, :mobile, :address, :privilages, :can_reset_password, :can_generate_code, :can_add_product, :can_add_place)
  end

  def admin_passwords_params
    params.require(:admin).permit(:password, :new_password, :password_confirmation)
  end

  def updated_user_params
    params.require(:user).permit(:id, :username, :password, :new_password, :password_confirmation)
  end

  def slider_images_params
    params.require(:slider_image).permit(:slider_image_1, :slider_image_2, :slider_image_3, :slider_image_4, :slider_image_5)
  end

  def calculation_params
    params.require(:calculation).permit(:max_out, :code_value, :renew, :minimum_product_price, :blanced_nodes_number, :code_value, :user_profit, :first_year, :number_of_product_credit_cheques_)
  end

  def user_params
    params.require(:user).permit(:username, :master_credit, :product_credit)
  end

  def user_info_params
    params.require(:user_info).permit(:first_name, :last_name, :email, :mobile, :land_phone, :address1, :address2, :postal_code, :national_id, :gender, :birthdate, :status_id, :region_id, :governorate_id, :country_id)
  end


end
