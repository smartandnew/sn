require 'will_paginate/array'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionHelper,ApplicationHelper
  before_filter :customer_carts,:get_store_contents


 
  
  def is_logged_in
    if user_is_signed_in?
      redirect_to profile_path
      return false
    elsif admin_is_signed_in?
      redirect_to admin_index_path
      return true
    else
      return false
    end
  end


  def customer_carts
    @cart_products = Array.new
    @cart_products_counts = Array.new
    @total_count =0
    @total_price =0
    # session[:product_ids] = nil
    if session[:product_ids] != nil
      for i in 0...session[:product_ids].length
        pro_id=session[:product_ids].fetch(i)["product_id"]
        pro_counts=session[:product_ids].fetch(i)["count"]
        pro=Product.find(pro_id)
        @cart_products << pro
        @cart_products_counts<<pro_counts
      end
    end

    for c in 0...@cart_products_counts.length
      @total_count += @cart_products_counts[c]
      @total_price += @cart_products[c].price*@cart_products_counts[c]
    end
  end

  def remove_product_from_cart
    product_index_in_session=params[:product_index]
    if product_index_in_session
      for i in 0...session[:product_ids].length
        pro_id=session[:product_ids].fetch(product_index_in_session)["product_id"]
        pro_counts=session[:product_ids].fetch(product_index_in_session)["count"]
        pro=Product.find(product_index_in_session)
        @cart_products >> pro
        @cart_products_counts >> pro_counts
      end
      params[:product_index]=nil
    end
  end



  def get_store_contents
    @application_categories=Category.connection.execute('SELECT c.*
    FROM categories c Left JOIN sub_categories sub
       ON c.id = sub.category_id  left JOIN products p
       ON p.sub_category_id=sub.id where p.quantity>0 group by c.id' )

  end
  # # show all categories in site
  def store_categories
    @categories =   @application_categories.paginate(:page => params[:page],:per_page=>9)
    render 'layouts/categories'
  end

  #
  #
  # show all sub categories of the selected category
  def store_sub_categories
    # if is_logged_in
    #   return
    # end
    category_id=params[:category_id]

    if category_id
      session[:selected_category_id]=category_id
      begin
        @selected_category=Category.find(session[:selected_category_id])
      rescue
        flash[:subcategories_not_found]="No subcategories found for that category  "
        redirect_to store_categories_path
        return
      end
      @category_sub_categories=  get_sub_categories_by_category_id(@selected_category.id)
      if @category_sub_categories && @category_sub_categories.count>0
         @category_sub_categories =   @category_sub_categories.paginate(:page => params[:page],:per_page=>9)
        render 'layouts/sub_categories'
      else
        flash[:subcategories_not_found]="No subcategories found for that category  "
        redirect_to store_categories_path
      end
    else
      redirect_to store_categories_path
    end
  end


  # show all products of the selected sub category
  def products
    # if is_logged_in
    #   return
    # end
    sub_category_id=params[:sub_category_id]
    if sub_category_id
      session[:selected_sub_category_id]=sub_category_id
      begin
        @selected_sub_category=SubCategory.find(session[:selected_sub_category_id])
      rescue
        flash[:products_not_found]="Products not found "
        redirect_to store_categories_path
        return
      end

      if @selected_sub_category
        session[:current]=1
        @sub_categories_products=Product.where("sub_category_id=? and quantity>?", session[:selected_sub_category_id],0)
        if @selected_sub_category && @sub_categories_products && @sub_categories_products.count>0
          @sub_categories_products =  @sub_categories_products.paginate(:page => params[:page],:per_page=>9)
          render 'layouts/products'
        else
          flash[:products_not_found]="Products not found "
          redirect_to store_categories_path
        end
      else
        flash[:products_not_found]="Products not found "
        redirect_to store_categories_path
      end

    else
      if session[:selected_sub_category_id]
        render 'layouts/products'
      else
        redirect_to store_categories_path
      end
    end
  end


  # show the selected product
  def product
    # if is_logged_in
    #   return
    # end
    product_id=params[:product_id]
    if product_id
      session[:selected_product_id]=product_id
      begin
        @selected_product=Product.find(session[:selected_product_id])
      rescue
        flash[:product_not_found]="No product found  "
        redirect_to store_categories_path
        return
      end

      if @selected_product&&@selected_product.quantity&&@selected_product.quantity!=0
        @selected_product =get_product_after_check_offer(@selected_product.id)
        session[:current]=2
        session[:selected_sub_category_id]=@selected_product.sub_category_id
        if File.exist?("app/assets/images/data/products/#{@selected_product.id}")
          @selected_product_images=get_product_images(@selected_product.id)
        end
        render 'layouts/product'
      else
        flash[:product_not_found]="Product not found "
        redirect_to store_categories_path
      end

    else
      if session[:selected_product_id]
        render 'layouts/product'
      else
        # flash[:products_not_found]="22222222222222222222222222222222222222222222 "
        redirect_to store_categories_path
      end

    end
  end

  # empty id of selected category in session
  def empty_selectd_category_id
    session[:selected_category_id]=nil
  end


  # empty id of selected sub category in session
  def empty_selectd_sub_category_id
    session[:selected_sub_category_id]=nil
  end


  # empty id of selected proflash[:error]="You are not authorized to navigate to this page "duct in session
  def empty_selectd_proudct_id
    session[:selected_product_id]=nil
  end


  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }
  end

  private
  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end

end
