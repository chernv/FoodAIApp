class CreateFoodImages < ActiveRecord::Migration
  def change
    create_table :food_images do |t|
      t.string :description
      t.text :categories
      t.text :foodtypes
      t.datetime :date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
