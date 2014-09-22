class UserMailer < ActionMailer::Base
  default from: "web.dev.peter@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signUp.subject
  #
  def signUp(email,code)
    @greeting = "thanks for sign up  your verify code is "
    @code=code
    @email=email
    mail( to: @email,subject: 'Sign up confirmation code')
  end

  def reset_password(email,username,password)
    @greeting = "You have reset passwor and your data"
    @password=password
    @username=username
    @email=email
    mail( to: @email,subject: 'Reset password')
  end

  def confirm_first_product(email,product)
    @greeting = "congratulation, you have completed your first product and the company will send it to you as soon as possible"
    @email=email
    @product=product
    mail( to: @email,subject: 'Completed your first product')
  end

  def confirm_order_mail(customer,product_sale)
    @greeting = "Thanks Mr.#{customer.name} for shopping in our store"
    @email=customer.email
    @product_sale=product_sale
    puts "email to:#{@email}"
    puts "data:#{@product_sale}"
    mail( to: @email,subject: ' Order Confirmation ')
  end

  def confirm_order_mail_user(user,product_sale)
    @greeting = "Thanks Mr.#{user.first_name} #{user.last_name} for shopping in our store"
    @email=user.email
    @product_sale=product_sale
    puts "email to:#{@email}"
    puts "data:#{@product_sale}"
    mail( to: @email,subject: ' Order Confirmation ')
  end
end
