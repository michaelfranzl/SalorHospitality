class AddConfirmationToItems < ActiveRecord::Migration
  def change
    add_column :items, :confirmation_count, :integer
  end
end
