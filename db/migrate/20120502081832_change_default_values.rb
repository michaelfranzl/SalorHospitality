class ChangeDefaultValues < ActiveRecord::Migration
  def change
    change_column :items, :comment, :string, :default => ''
    change_column :items, :preparation_comment, :string, :default => ''
    change_column :quantities, :prefix, :string, :default => ''
    change_column :quantities, :postfix, :string, :default => ''
    change_column :items, :usage, :integer, :default => 0
    add_column :items, :delivery_comment, :string, :default => ''
  end
end
