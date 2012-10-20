class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.integer :ticket_id
      t.string :firstname
      t.string :lastname
      t.string :company
      t.string :about
      t.datetime :approved_at
      t.string :key
      t.string :email
      t.string :twitter_handle
      t.string :title
      t.string :badge_type
      t.string :buyer_firstname
      t.string :buyer_lastname
      t.string :buyer_email
      t.boolean :vegetarian

      t.timestamps
    end
  end
end
