module StoreHelper
def get_user_info_by_sale(sale)
    expense=Expense.find_by_sale_id(sale.id)
    if expense
      user_info=UserInfo.find_by_user_id(expense.user_id)
    return user_info
    end
  end

  def get_product_has_sale_from_sale(sale)
    product_has_sales=ProductHasSale.where("sale_id=?",sale.id)
    if product_has_sales
    return product_has_sales
    end
  end

  def get_product_by_product_sale(product_has_sale)
    product=Product.find(product_has_sale.product_id)
    if product
    return product
    end
  end

  def get_total_of_sale(sale)
    product_has_sales=ProductHasSale.where("sale_id=?",sale.id)
    total=0
    if product_has_sales
      product_has_sales.each  do|ps|
        total+=(ps.price*ps.amount)
      end
    return total
    end
  end
end
