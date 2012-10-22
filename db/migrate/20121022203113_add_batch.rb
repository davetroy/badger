class AddBatch < ActiveRecord::Migration
  def up
    add_column :badges, :batch, :integer
  end

  def down
    remove_column :badges, :batch
  end
end
