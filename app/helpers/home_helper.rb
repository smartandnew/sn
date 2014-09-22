module HomeHelper
  # return an array of all images file names for a given product
  def get_slider_images
    return Dir.glob("app/assets/images/slider_images/*").map do |f|
                  File.basename f
                   end.sort
  end
end
