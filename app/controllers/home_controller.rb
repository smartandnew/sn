class HomeController < ApplicationController
  include SessionHelper
  def about_us
  end

  def contact_us
  end

  def delivery_information
  end

  def terms_conditions
  end

  def privacy_policy
  end

  def index
    # if user_is_signed_in?
    # redirect_to profile_path
    # end
    # UserMailer.signUp("proragab@gmail.com","132156").deliver
    slider_images_dir_name="app/assets/images/slider_images"
    if File.exist?(slider_images_dir_name)
      @slider_images=Dir.glob(slider_images_dir_name+"/*").map do |f|
        File.basename f
      end.sort
    else
      @slider_images=Array.new
    end
  end
end
