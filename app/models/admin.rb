require 'bcrypt'

class Admin < ActiveRecord::Base
  has_many :codes
  attr_accessor :password
  attr_accessor :new_password
  attr_accessor :password_confirmation
  attr_accessor :can_reset_password
  attr_accessor :can_generate_code
  attr_accessor :can_add_product
  attr_accessor :can_add_place
  attr_accessor :conf_pass_for_gen_code

  email_regex = /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i

  username_regex=/\A[a-z0-9_-]{6,20}\Z/
  email_regex = /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i
  name_regex = /\A^[A-Za-z ,.'-]+$\Z/i
  validates :first_name, :length =>{:in=> 2..15},presence: true , :format => {:with => name_regex}
  validates :last_name,:length =>{:in=> 2..15}, presence: true, :format => {:with => name_regex}
  
  validates :username, :presence => true ,:length => {:in =>6..20},
  :uniqueness => {:case_sensitive => false},:format => { :with=> username_regex, :message=>'user name must be english letter, numbers, and/or _ '}
  validates :password, :presence => true, :length => {:in => 6..40}
  validates :email, :presence => true, :confirmation => true,
  :format => {:with => email_regex }, :uniqueness=> {:case_sensitive => false}
  validates :mobile, :presence => true, :length => {:in => 10..15}
  validates :address, :presence => true
  validates :privilages, :presence => true
  before_create :encrypt_password
  before_update :encrypt_new_password
  def self.authenticate(username, password)
    admin = find_by_username(username)
    if admin && admin.password_hash == BCrypt::Engine.hash_secret(password, admin.password_salt)
    admin
    else
      nil
    end
  end

  def self.authenticate_with_salt(id, cookie_salt)
    admin = find_by_id(id)
    (admin && admin.salt == cookie_salt) ? user : nil
  end

  def encrypt_password

    if self.password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(self.password, self.password_salt)
    end
  end

  def encrypt_new_password

    if self.new_password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(self.new_password, self.password_salt)
    end
  end
end
