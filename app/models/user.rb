require 'bcrypt'
require 'thread'

# require "whenever/capistrano"
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :new_password
  attr_accessor :password_confirmation
  attr_accessor :user_conf_pass_for_gen_code
  has_many :cheques
  has_one :first_product , :dependent => :destroy
  has_many :expenses
  has_one :tree ,:dependent => :destroy
  has_one :user_info ,:dependent => :destroy
  belongs_to :code

  username_regex=/\A[a-z0-9_-]{6,20}\Z/
  accepts_nested_attributes_for :user_info
  validates :username,:presence=>true, :uniqueness=> {:case_sensitive => false},
            :length=>{:in => 6..20},:format => { :with=> username_regex, :message=>' must be english letter, numbers, and/or _ '}
  validates :password, :presence => true, :length => {:in => 6..40}
  validates :master_credit, :presence => true
  validates :product_credit, :presence => true,:numericality => {:greater_than_or_equal_to => 0}
  validates :code_id,:presence => true

  before_create :before_create_user
  before_update :encrypt_new_password
  def self.authenticate(username, password)
    user = find_by_username(username)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
    user
    else
      nil
    end
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def before_create_user
    self.master_credit=0
    self.product_credit=0
    encrypt_password
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

  @@mutex=Mutex.new
  @@scheduler = Rufus::Scheduler.new
  @@count =0

  def  year_renew
    start_date=Time.new(Time.now.year,self.created_at.to_time.month,self.created_at.to_time.day,self.created_at.to_time.hour,self.created_at.to_time.min,self.created_at.to_time.sec)
    year_renew=Time.now.year-self.created_at.to_date.year
    renew_current_year_count=Expense.where("is_master = ? and (code_id is null) and (sale_id is null) and user_id=? and ( created_at between ? and ?)", true, self.id,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).count
    month=Time.now.month-self.created_at.to_date.month
    day=Time.now.day-self.created_at.to_date.day
    puts"renew count:#{renew_current_year_count}"
    if renew_current_year_count==0 && year_renew>0 && month==0 &&day==0
      renew_every_year
    return
    else
      start_date=Time.new(Time.now.year+1,self.created_at.to_date.month,self.created_at.to_date.day,self.created_at.to_time.hour,self.created_at.to_time.min,self.created_at.to_time.sec)
    end
    puts"#{start_date}"
    @@scheduler.every '365d',:first_in=>start_date   do
      puts "every"
      @@mutex.synchronize do
        puts "==========================="
        puts "#{self.id}=#{self.username}"
        c= Calculation.first
        self.update_attribute(:master_credit, self.master_credit-c.renew)
        Expense.create(:date=>Time.now,:value=>c.renew,:user_id=>self.id,:is_master=>true,:is_money=>false,:sale_id=>nil,:code_id=>nil)
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
    @@count=@@count+1
    puts "end method count:#{@@count}"
  end

  def renew_every_year
    puts "renew is today"
    @@scheduler.every '365d' , :first_in=>'1s'do
      @@mutex.synchronize do
        puts "==========================="
        puts "#{self.id}=#{self.username}"
        c= Calculation.first
        self.update_attribute(:master_credit, self.master_credit-c.renew)
        Expense.create(:date=>Time.now,:value=>c.renew,:user_id=>self.id,:is_master=>true,:is_money=>false,:sale_id=>nil,:code_id=>nil)
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end
