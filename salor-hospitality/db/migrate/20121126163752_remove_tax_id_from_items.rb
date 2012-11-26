class RemoveTaxIdFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :tax_id
  end

  def down
    add_column :items, :tax_id, :integer
  end
end
