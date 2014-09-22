class Calculation < ActiveRecord::Base
  validates :max_out,:presence=>true,:numericality => {:greater_than => 0}
  validates :renew,:presence=>true,:numericality => {:greater_than => 0}
  validates :user_profit,:presence=>true,:numericality => {:greater_than => 0}
  validates :first_year,:presence=>true,:numericality => {:greater_than => 0}
  validates :minimum_product_price,:presence=>true,:numericality => {:greater_than => 0}
  validates :code_value ,:presence=>true,:numericality => {:greater_than => 0}
  validates :blanced_nodes_number,:presence=>true,:numericality => {:greater_than => 0}
  validates :number_of_product_credit_cheques_,:presence=>true,:numericality => {:greater_than => 0}
end
