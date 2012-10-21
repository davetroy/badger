class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :ticket_id
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
      t.datetime :emailed_at
      
      t.timestamps
    end
    
    add_index :badges, :key
    add_index :badges, :ticket_id
  end
end
