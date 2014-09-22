class UserInfo < ActiveRecord::Base
  attr_accessor :parent
  belongs_to :status
  belongs_to :users
  belongs_to :region

  GENDER_TYPES=["male" , "female"]
  attr_accessor :governorate_id
  attr_accessor :country_id
  email_regex = /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i
  name_regex = /\A^[A-Za-z ,.'-]+$\Z/i
  validates :first_name, :length =>{:in=> 2..15},presence: true , :format => {:with => name_regex}
  validates :last_name,:length =>{:in=> 2..15}, presence: true, :format => {:with => name_regex}
  validates :email,:presence=>true ,:confirmation=> true, :format =>{:with=>email_regex},
  :uniqueness=> {:case_sensitive => false}
  validates :address1 ,:presence=>true
  validates :mobile ,:presence=>true,:length =>{:in=> 10..15}
  validates :postal_code,:presence=>true,:length=> { :in=> 3..10 }
  validates :national_id ,:presence=>true, :length=> { :is=> 14 }, :uniqueness=> true
  validates :birthdate ,:presence=>true
  validates :region_id,:presence=>true
  validates :status_id,:presence=>true
  validates :user_id,:presence=>true

  # after_create :create_node

  def create_node
    Tree.create!(:id=>self.user_id,:user_id=>self.user_id,:parent=>self.parent,:left=>0,:right=>0,:virtual_right_count=>0,:virtual_left_count=>0,:total_left=>0,:total_right=>0,:virtual_credit=>0,:level=>1,:total_cheque_count=>0)
  end

  def create_node_params(parent_id,user_id)
    Tree.create!(:id=>user_id,:user_id=>user_id,:parent=>parent_id,:left=>0,:right=>0,:virtual_right_count=>0,:virtual_left_count=>0,:total_left=>0,:total_right=>0,:virtual_credit=>0,:level=>1,:total_cheque_count=>0)
  end

  def save_user_info(parent)
    self.parent=parent
    self.save
  end
end
