class FoodImage < ActiveRecord::Base
  belongs_to :user
  serialize :categories, Array
  serialize :foodtypes, Array
  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :foodimg, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }, default_url: "https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg"

  # validates_attachment_content_type :foodimg, :content_type => /\Aimage\/.*\Z/

  def img_url
  	foodimg.url#[:medium]
  end

  def self.init(new_fi, img, image_name)
  	food_image = new_fi
    food_image.foodimg = img
    food_image.foodimg_file_name = image_name
    food_image
  end
  # # Validate the attached image is image/jpg, image/png, etc
  do_not_validate_attachment_file_type :foodimg
  
end
