class AddAttachmentFoodimgToFoodImages < ActiveRecord::Migration
  def self.up
    change_table :food_images do |t|
      t.attachment :foodimg
    end
  end

  def self.down
    remove_attachment :food_images, :foodimg
  end
end
