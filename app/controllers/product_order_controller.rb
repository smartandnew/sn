class ProductOrderController < ApplicationController
  #include SessionHelper
  #include AdminHelper
  #before_filter :go_profile_if_signed_in
  #before_filter :go_index_if_signed_in
  def empty_cart
    session[:product_ids]=nil
    @cart_products = Array.new
    @cart_products_counts = Array.new
    @total_count =0
    @total_price =0
    respond_to do |format|
      format.html{}
      format.js
      format.json
    end
  end

  def add_to_cart
    if session[:product_ids]==nil
      session[:product_ids]=Array.new
    end
    begin
      @pro= Product.find(String(product_id).to_i)
    rescue
      respond_to do |format|
        format.html{}
        format.js
        format.json
      end
    return
    end
    isInArray=false
    for p in 0...session[:product_ids].length
      if session[:product_ids].fetch(p)["product_id"]== String(product_id).to_i
        count=session[:product_ids].fetch(p)["count"]
        product_id_= session[:product_ids].fetch(p)["product_id"]

        pro=Product.find_by_id(product_id_)
        if pro.quantity>=count+1
          session[:product_ids].delete_at(p)
          session[:product_ids].insert(p, {:product_id => product_id_, :count => count+1})
        end
      isInArray=true
      end
    end
    if !isInArray
      if @pro.quantity>=1
        session[:product_ids].push({:product_id => String(product_id).to_i, :count => 1})
      end
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def create_product_order_old_customer
    if session[:product_ids]==nil||session[:product_ids].empty?
      redirect_to store_categories_path
    return
    end
    remove_spaces_from_number_fields(old_customer_params)
    @customer_old=Customer.find_by(:phone => old_customer_params[:phone])
    if @customer_old
      if @customer_old.update_attribute(:address, old_customer_params[:address])
        save_sale(@customer_old)
      else
        @customer_new=Customer.new
        render 'add_product_order'
      end
    else
      @customer_old=Customer.new
      @customer_new=Customer.new
      flash.now[:error]="customer not found"
      render 'add_product_order'
    end
  end

  def add_product_order
    if session[:product_ids]==nil||session[:product_ids].empty?
      redirect_to store_categories_path
    return
    end
    @customer_new=Customer.new
    @customer_old=Customer.new
  end

  def create_product_order
    if session[:product_ids]==nil||session[:product_ids].empty?
      redirect_to store_categories_path
    return
    end
    remove_spaces_from_number_fields(customer_params)
    @customer_new=Customer.new(customer_params)
    if @customer_new
      if @customer_new.save
        save_sale(@customer_new)
      else
        @customer_old=Customer.new
        render 'add_product_order'
      end
    else
      @customer_old=Customer.new
      @customer_new=Customer.new
      render 'add_product_order'
    end
  end
  
  @@mutex=Mutex.new
  def save_sale(customer)
    sale=Sale.new(:date => Time.now, :customer_id => customer.id,:is_delivered=>false)
    product_sale=Array.new
    if sale.save
      for p in 0...session[:product_ids].length
        count=session[:product_ids].fetch(p)["count"]
        product_id_= session[:product_ids].fetch(p)["product_id"]
        @@mutex.synchronize do
          product=Product.find_by_id(product_id_)
          if product.quantity>0&& product.quantity>=count
          if product.update_attribute(:quantity,product.quantity-count)
                price=0
             if product.offer&&product.offer>0&&product.offer_expired_date && Date.today<=product.offer_expired_date
                offer_price=product.price-(product.price* (product.offer / 100));
                ProductHasSale.create!(:sale_id => sale.id, :product_id => product.id, :price => offer_price, :real_price => product.real_price, :amount => count)
                price=offer_price
              else
                ProductHasSale.create!(:sale_id => sale.id, :product_id => product.id, :price => product.price, :real_price => product.real_price, :amount => count)
                price=product.price
             end
             product_sale.push({:prodduct_name=>product.name,:quantity=>count,:price=>price})
          end
          else

          end
        end
      end
      Thread.new do
        puts "=======================sending email=============="
        begin
          UserMailer.confirm_order_mail(customer,product_sale).deliver
        rescue Exception => e
          puts "email send fail:#{e.inspect}"
        end
      end
      session[:product_ids]=nil
      flash[:success]="Checkout completed succesffully and email sent to #{customer.email} "
    end
    session[:product_ids]=nil
    redirect_to store_categories_path
  end

  def remove_product_from_cart
    product_index_in_session=params[:product_index]
    puts"product to remove:#{product_index_in_session}"
    puts"session before delete:#{session[:product_ids]}"
    if product_index_in_session
      session[:product_ids].delete_at(String(product_index_in_session).to_i)
      params[:product_index]=nil
    end
    puts"session after delete:#{session[:product_ids]}"
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def  remove_spaces_from_number_fields(customer_params)
    mobile=String(customer_params[:phone]).strip.to_i
    customer_params[:phone]=mobile
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone, :address, :email)
  end

  def old_customer_params
    params.require(:customer).permit(:phone, :address)
  end

  def product_id
    par= params[:product_to_cart_id]
    return par
  end
end
