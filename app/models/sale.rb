class Sale < ActiveRecord::Base
  belongs_to :customer
  has_many :products ,:through=> :product_has_sale
  has_one :expense
  validates :date, :presence => true
  
end
