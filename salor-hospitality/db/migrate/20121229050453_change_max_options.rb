class ChangeMaxOptions < ActiveRecord::Migration
  def up
    change_column :vendors, :max_options, :integer
  end

  def down
    change_column :vendors, :max_options, :integer, :default => 5
  end
end
