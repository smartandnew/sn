class StoreController < ApplicationController
  respond_to :html, :json
  include AdminHelper, ApplicationHelper
  before_filter :authenticate_admin, :validate_store_privileges

  def index

  end

  def add_category
    @category=Category.new
  end

  def create_category
    category_name=category_params[:name].to_s.strip.downcase
    @category= Category.new
    @category.name=category_name
    if @category
      if @category.save
        if category_params[:category_image]
          create_image_file(1, @category.id.to_s, category_params[:category_image], false, @category.id)
        end
        redirect_to store_path
      else
        render 'add_category'
      end
    else
      render 'add_category'
    end

  end

  def add_sub_category
    @sub_category=SubCategory.new
  end

  def create_sub_category
    @sub_category=SubCategory.new
    @sub_category.name=sub_category_params[:name].to_s.strip.downcase
    @sub_category.category_id = sub_category_params[:category_id]
    similar_sub_categories=SubCategory.where(" name=? and category_id=?", @sub_category.name, @sub_category.category_id).count
    if similar_sub_categories >0
      flash.now[:error]="Another sub_category already exists "
      @sub_category=SubCategory.new
      render 'add_sub_category'
      return
    else
      if @sub_category.save
        if sub_category_params[:sub_category_image]
          create_image_file(2, @sub_category.id.to_s, sub_category_params[:sub_category_image], false, @sub_category.id)
        end
        flash[:success]=" Sub_category successfully created "
        redirect_to store_path
      else
        render 'add_sub_category'
      end
    end
  end

  def add_product
    @product=Product.new
  end

  def create_product
    remove_spaces_from_number_fields(product_param)
    @product=Product.new(product_param)
    if validate_offer(@product.offer, @product.offer_expired_date) && validate_real_price(product_param[:price], product_param[:real_price])
      if  @product.save
        upload_product_images(@product.id.to_s)
        flash.now[:success]=" Product successfully created "
        redirect_to store_path
      else
        render 'add_product'
      end
    else
      render 'add_product'
    end
  end


  def remove_spaces_from_number_fields(product_param)
    price=String(product_param[:price]).strip.to_i
    product_param[:price]=price
    quantity=String(product_param[:quantity]).strip.to_i
    product_param[:quantity]=quantity
    real_price=String(product_param[:real_price]).strip.to_i
    product_param[:real_price]=real_price
    offer=String(product_param[:offer]).strip.to_i
    product_param[:offer]=offer
  end

  def upload_product_images(product_id)
    if product_param[:datafile1]
      create_image_file(3, product_id, product_param[:datafile1], false, 1)
    end
    if product_param[:datafile2]
      create_image_file(3, product_id, product_param[:datafile2], false, 2)
    end
    if product_param[:datafile3]
      create_image_file(3, product_id, product_param[:datafile3], false, 3)
    end
  end

  def store_categories
    empty_selectd_proudct_id
    empty_selectd_sub_category_id
    empty_selectd_proudct_id
    @categories=Category.all.paginate(:page => params[:page], :per_page => 9)

  end

  def update_category_name
    @selected_category=Category.find(session[:selected_category_id])
    if @selected_category
      category_name=category_params[:name].to_s.strip.downcase
      category_params={:name => category_name}
      if @selected_category.valid? && @selected_category.update_attributes(category_params)
        if category_params[:category_image]
          create_image_file(1, @selected_category.id.to_s, category_params[:category_image], true, @selected_category.id)
        end
        flash[:success]="Category  updated successfully #{@selected_category.name} "
      else
        @sub_categories=SubCategory.where("category_id=?", session[:selected_category_id]).
            paginate(:page => params[:page], :per_page => 9)
        @to_be_updated_category=Category.find(session[:selected_category_id])
        render 'sub_categories'
        return
      end
    else
      flash[:category_updated_error]="Not authorized"
    end
    redirect_to admin_store_categories_path
  end

  def sub_categories
    empty_selectd_proudct_id
    empty_selectd_category_id
    empty_selectd_sub_category_id
    category_id=params[:category_id]
    @category_images=nil
    if category_id
      session[:selected_category_id]=category_id
      @selected_category=Category.find(session[:selected_category_id])
      if @selected_category
        @to_be_updated_category=@selected_category
        if File.exist?("app/assets/images/data/categories/#{@selected_category.id}")
          @category_images=get_category_images(@selected_category.id)
        end
      end
      @sub_categories=SubCategory.where("category_id=?", session[:selected_category_id]).
          paginate(:page => params[:page], :per_page => 9)
    else
      redirect_to admin_store_categories_path
    end
  end

  def update_sub_category_name
    @selected_sub_category=SubCategory.find(session[:selected_sub_category_id])
    if @selected_sub_category
      similar_sub_categories=SubCategory.where("id !=? and name=? and category_id=?", session[:selected_sub_category_id], sub_category_params[:name].to_s.strip.downcase, sub_category_params[:category_id]).count
      if similar_sub_categories >0
        flash.now[:error]="Another sub_category already exists "
        @selected_sub_category=SubCategory.find(session[:selected_sub_category_id])
        @products=Product.where("sub_category_id=?", session[:selected_sub_category_id]).
            paginate(:page => params[:page], :per_page => 9)
        render 'products'
        return
      else
        @selected_sub_category.name=sub_category_params[:name].to_s.strip.downcase
        if @selected_sub_category.valid? && @selected_sub_category.update_attributes(:name=>(sub_category_params[:name].to_s.strip.downcase),:category_id=>sub_category_params[:category_id])
          if sub_category_params[:sub_category_image]
            create_image_file(2, @selected_sub_category.id.to_s, sub_category_params[:sub_category_image], true, @selected_sub_category.id)
          end
          flash[:success]="Sub Category  updated successfully #{@selected_sub_category.name} "
        else
          @products=Product.where("sub_category_id=?", session[:selected_sub_category_id]).
              paginate(:page => params[:page], :per_page => 9)
          render 'products'
          return
        end
      end
    else
      flash[:error]="Not authorized "
    end
    redirect_to admin_store_categories_path
  end

  def products
    empty_selectd_proudct_id
    empty_selectd_category_id
    sub_category_id=params[:sub_category_id]

    if sub_category_id || session[:selected_sub_category_id]
      if !session[:selected_sub_category_id]
        session[:selected_sub_category_id]=sub_category_id
      end
      @selected_sub_category=SubCategory.find(session[:selected_sub_category_id])
      if @selected_sub_category
        if File.exist?("app/assets/images/data/sub_categories/#{@selected_sub_category.id}")
          @sub_category_images=get_sub_category_images(@selected_sub_category.id)
        end
      end
      @products=Product.where("sub_category_id=?", session[:selected_sub_category_id]).
          paginate(:page => params[:page], :per_page => 9)
    else
      redirect_to admin_store_categories_path
    end
  end

  def product
    product_id=params[:product_id]
    empty_selectd_sub_category_id
    if product_id || session[:selected_product_id]
      if !session[:selected_product_id]
        session[:selected_product_id]=product_id
      end
      @selected_product=Product.find(session[:selected_product_id])

      if File.exist?("app/assets/images/data/products/#{@selected_product.id}")
        @selected_product_images=get_product_images(@selected_product.id)
        # @selected_product_images.sort
      end

    else
      redirect_to admin_store_categories_path
    end
  end

  def update_product
    if session[:selected_product_id]
      @selected_product=Product.find(session[:selected_product_id])
      if @selected_product
        remove_spaces_from_number_fields(product_param)
        if validate_offer(product_param[:offer], product_param[:offer_expired_date])&& validate_real_price(product_param[:price], product_param[:real_price])
          @selected_product.update_attributes(product_param)
          if @selected_product.valid?
            change_product_images(@selected_product.id.to_s)
            flash[:success]="Product  updated successfully  "
            session[:selected_sub_category_id]=@selected_product.sub_category_id
            redirect_to admin_store_products_path
          else
            @selected_product_images=Dir.glob("app/assets/images/data/products/#{@selected_product.id}/*")
            render 'product'
          end
        else
          @selected_product=Product.find(session[:selected_product_id])
          @selected_product_images=Dir.glob("app/assets/images/data/products/#{@selected_product.id}/*")
          render 'product'
        end
      else
        flash[:error]="product is in valid  "
        redirect_to admin_index_path
      end
    else
      flash.now[:product_updated_error]="Not authorized  "
      redirect_to admin_index_path
    end

  end

  def change_product_images(product_id)
    if File.exist?("app/assets/images/data/products/#{@selected_product.id}")
      @product_images=Dir.glob("app/assets/images/data/products/#{@selected_product.id}/*").map do |f|
        File.basename f
      end.sort
    end
    if product_param[:datafile1]
      create_image_file(3, product_id, product_param[:datafile1], true, 1)
    end
    if product_param[:datafile2]
      create_image_file(3, product_id, product_param[:datafile2], true, 2)
    end
    if product_param[:datafile3]
      create_image_file(3, product_id, product_param[:datafile3], true, 3)
    end
  end

  def create_image_file(type, object_id, param, is_updating_existed_image, file_name)
    if type==1
      directory_name = "app/assets/images/data/categories/"+object_id
    elsif type==2
      directory_name = "app/assets/images/data/sub_categories/"+object_id
    else
      directory_name = "app/assets/images/data/products/"+object_id
    end
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    extention = File.extname(param.original_filename)
    lower_case_extention=extention.downcase
    if lower_case_extention==".jpg" || lower_case_extention ==".jpeg"|| lower_case_extention==".png"|| lower_case_extention==".gif"
      name= file_name.to_s+extention
      if is_updating_existed_image
        @images=Dir.glob(directory_name+"/*").map do |f|
          File.basename f
        end.sort
        if @images && @images.count>0
          if type ==3
            begin
              File.delete(directory_name+"/"+@images[file_name-1])
            rescue
            end
          else
            File.delete(directory_name+"/"+@images[0])
          end
        end
      end
      # create the file path
      path = File.join(directory_name, name)
      # write the file
      File.open(path, "wb") { |f| f.write(param.read) }
    else
      flash.now[:error]="Please, select an jpeg,jpg,png or gif file only "
    end
  end

  def all_products
    @all_products = Product.all
  end

  def empty_selectd_category_id
    session[:selected_category_id]=nil
  end

  def empty_selectd_sub_category_id
    session[:selected_sub_category_id]=nil
  end

  def empty_selectd_proudct_id
    session[:selected_product_id]=nil
  end

  def validate_store_privileges
    unless @current_admin.is_super_admin
      unless @current_admin.privilages.include? '3'
        redirect_to admin_index_path
      end
    end
  end

  def validate_offer (offer, offer_expired_date)
    @valid=true
    if offer
      if !offer_expired_date
        flash.now[:error]="please, define offer expired date ."
        @valid=false
      end
    end
    if offer_expired_date && offer_expired_date.to_date
      if offer_expired_date.to_date<Date.today
        flash.now[:error]="please, define up coming date of offer date."
        @valid=false
      end
      if !offer
        flash.now[:error]="please, define offer percentage ."
        @valid=false
      end
    end
    return @valid
  end

  def validate_real_price(price, real_price)
    @valid=true
    if price.to_i<real_price.to_i
      flash.now[:real_price_invalid]="Price must be greater than real price ."
      @valid=false
    end
    return @valid
  end


  def check_proudct_is_featured(is_featured, is_best_seller)
    @valid=true
    if is_featured && is_featured=="1"
      if is_best_seller && is_best_seller=="1"
        @valid=false
      end
    end
    if is_best_seller && is_best_seller=="1"
      if is_featured && is_featured=="1"
        @valid=false
      end
    end
    if !@valid
      flash.now[:error]="product can't be featured and best seller at the same time "
    end
    return @valid
  end

  private
  def category_params
    params.require(:category).permit(:name, :category_image)
  end

  def sub_category_params
    params.require(:sub_category).permit(:name, :category_id, :sub_category_image)
  end

  def product_param
    params.require(:product).permit(:sub_category_id, :name, :price, :description, :quantity, :real_price, :offer, :offer_expired_date, :is_featured, :is_best_seller, :datafile1, :datafile2, :datafile3)
  end
end

