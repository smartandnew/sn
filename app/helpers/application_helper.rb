module ApplicationHelper
  #return all sub categories  of a given category where
  #all products in those sub categories  have quantity more than 1
  def get_sub_categories_by_category_id(category_id)
    return SubCategory.connection.execute("SELECT sub.*
    		FROM sub_categories sub Left JOIN  products p
       		ON p.sub_category_id=sub.id
       		where sub.category_id ="+category_id.to_s+" and p.quantity>0 group by sub.id" )
  end

  # return count of products for a given sub category
  def get_products_count(sub_category_id)
    return Product.where("sub_category_id=? and quantity>?", sub_category_id,0).count
  end

  # return an array of all images file names for a given product
  def get_product_images(product_id)
    return Dir.glob("app/assets/images/data/products/#{product_id}/*").map do |f|
      File.basename f
    end.sort
  end

  # return an array of all images file names for a given sub_category
  def get_sub_category_images(sub_category_id)
    return Dir.glob("app/assets/images/data/sub_categories/#{sub_category_id}/*").map do |f|
      File.basename f
    end.sort
  end

  # return an array of all images file names for a given category
  def get_category_images(category_id)
    return Dir.glob("app/assets/images/data/categories/#{category_id}/*").map do |f|
      File.basename f
    end.sort
  end

  def get_product_after_check_offer(product_id)
      product=Product.find(product_id)
      if product
        if product.offer_expired_date && Date.today>product.offer_expired_date
          product.update_attribute(:offer,0)
          product.update_attribute(:offer_expired_date,"")
        end
        return product
      end
    end
  def get_product_from_session(index)
    pro_id=session[:product_ids].fetch(index)[:product_id]
    if !pro_id
      pro_id=session[:product_ids].fetch(index)["product_id"]
    end
      pro=Product.find_by_id(pro_id)
    return pro
  end

  def get_product_count_from_session(index)
    pro_counts=session[:product_ids].fetch(index)[:count]
    if !pro_counts
      pro_counts=session[:product_ids].fetch(index)["count"]
    end
    return pro_counts
  end

  def get_total_price_and_count_of_product_in_session
    @total_count_of_product=0;
    @total_price_of_product=0;
    if session[:product_ids]
      for i in 0...session[:product_ids].length
        pro_id=session[:product_ids].fetch(i)[:product_id]
        if !pro_id
          pro_id=session[:product_ids].fetch(i)["product_id"]
        end
        pro_counts=session[:product_ids].fetch(i)[:count]
        if !pro_counts
          pro_counts=session[:product_ids].fetch(i)["count"]
        end
        pro=Product.find(pro_id)
        @total_count_of_product+=pro_counts
        if pro.offer && pro.offer>0&&pro.offer_expired_date
            @total_price_of_product+=pro_counts*(pro.price-(pro.price* (pro.offer / 100)))
        else
          @total_price_of_product+=pro_counts*pro.price
       end
      end
    end

  end

  # return last 5 product taht have been added
  def get_last_5_products
    return Product.connection.execute("SELECT p.* FROM  products p where p.quantity>0 ORDER BY p.id DESC LIMIT 5" )
  end

  #get all featured products
  def get_featured_products
    return Product.where("quantity >? and is_featured=?",0,true)
  end

  #get all best seller products
  def get_best_seller_products
    return Product.where("quantity >? and is_best_seller=?",0,true)
  end

  #get specail products that have offer more than 20%
  def get_special_products
    return Product.where("quantity >? and offer >=?",0,20)
  end
end
