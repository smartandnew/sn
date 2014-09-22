class Product < ActiveRecord::Base
  # attr_accessor :sub_category_name
  attr_accessor :datafile1
  attr_accessor :datafile2
  attr_accessor :datafile3
  # before_create :get_sub_category
  belongs_to :sub_category
  has_many :sales ,:through=> :product_has_sale
  validates :name, :presence => true
  validates :price, :presence => true
  validates :description, :presence => true
  validates :real_price, :presence => true
  validates :sub_category_id,:presence => true

  SUB_CATEGORIES=SubCategory.pluck(:name)

  def get_sub_category
    if self.sub_category_name.present?
      @sub_category=SubCategory.find_by_name(self.sub_category_name)
      if @sub_category
        self.sub_category_id=sub_category.id
      else
      self.sub_category_id=100
      end
    end
  end
end
