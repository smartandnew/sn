module UserHelper
  # returnProductHasSale object from database using sale_id
  def get_product_sale_by_sale_id(sale_id)
    return ProductHasSale.find_by_sale_id(sale_id)
  end

  # return Product object from database using product_id
  def get_product_by_id(product_id)
    return Product.find(product_id)
  end

  def get_user_by_first_product(first_product)
    return User.find(first_product.user_id)
  end

  def get_user_info_by_first_product(first_product)
    return UserInfo.find_by_user_id(first_product.user_id)
  end

  def get_first_product_sub_category(products)
    sub_cat=Array.new
    products.each do |product|
      check=true
      sub_cat.each do |sub|
        if product.sub_category.id==sub.id
        check=false
        end
      end
      if check==true
      sub_cat.push(product.sub_category)
      end
    end
    return sub_cat
  end

  def get_first_product_in_sub_category(products,sub_category)
    product_in_sub=Array.new
    products.each do |product|
      if product.sub_category.id==sub_category.id
      product_in_sub.push(product)
      end
    end
    return product_in_sub
  end

end
