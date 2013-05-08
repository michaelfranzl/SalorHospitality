class AddUserIdToTaxItems < ActiveRecord::Migration
  def change
    add_column :tax_items, :user_id, :integer
  end
end
