class Customer < ActiveRecord::Base
  has_many :sales
  validates :name,:presence=>true,:length =>{:in=> 3..30}
  validates :phone,:presence=>true,:uniqueness=>true,:length =>{:in=> 10..15}
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,:presence=>true ,:confirmation=> true, :format =>{:with=>email_regex},
  :uniqueness=> {:case_sensitive => false}
  validates :address ,:presence=>true
end
