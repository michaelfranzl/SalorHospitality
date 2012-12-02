class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.string :permissions, :default => [], :limit => 1000

      t.timestamps
    end
# 
#     role = Role.create :name => 'admin', :permissions => ['take_orders', 'decrement_items', 'finish_orders', 'split_items', 'move_tables', 'make_storno', 'assign_cost_center', 'move_order', 'change_waiter', 'manage_articles_categories_options', 'finish_all_settlements', 'finish_own_settlement', 'view_all_settlements', 'manage_business_invoice', 'view_statistics', 'manage_users', 'manage_settings']
# 
#     User.all.each do |u|
#       u.update_attribute :role_id, role.id
#     end
  end

  def self.down
    drop_table :roles
  end
end
