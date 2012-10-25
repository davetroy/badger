class AddLogoCount < ActiveRecord::Migration
  def up
    add_column :badges, :logo_count, :integer, :default => 0
  end

  def down
    remove_column :badges, :logo_count
  end
end
