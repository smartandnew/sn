class ProductHasSale < ActiveRecord::Base
  belongs_to :product
  belongs_to :sale
  validates :price, :presence => true
  validates :real_price, :presence => true
  validates :product_id,:presence => true
  validates :sale_id,:presence => true
end
