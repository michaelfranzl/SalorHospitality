class AddReactivatedToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :reactivated, :boolean
    add_column :orders, :reactivated_by, :integer
    add_column :orders, :reactivated_at, :datetime
  end
end
