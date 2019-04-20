class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ''
      t.string :password_digest, null: false, default: ''
      t.string :display_name
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :image_url
      # t.string :image_file_name
      # t.string :image_content_type
      # t.integer :image_file_size
      # t.datetime :image_updated_at   
      t.string :encrypted_password
      t.string :facebook
      t.string :google

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
