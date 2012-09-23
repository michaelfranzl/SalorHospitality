class ChangeDatatypes < ActiveRecord::Migration
  def self.up
    change_column :items, :count, :tinyint
    change_column :items, :printed_count, :tinyint,  :default => 0
    change_column :items, :storno_status, :tinyint,  :default => 0
    change_column :items, :count, :tinyint
    change_column :articles, :usage, :tinyint,  :default => 0
    change_column :quantities, :usage, :tinyint,  :default => 0
    change_column :categories, :usage, :tinyint,  :default => 0
  end

  def self.down
    change_column :items, :count, :integer
    change_column :items, :printed_count, :integer,  :default => 0
    change_column :items, :storno_status, :integer,  :default => 0
    change_column :items, :count, :integer
    change_column :articles, :usage, :string
    change_column :quantities, :usage, :string
    change_column :categories, :usage, :string
  end
end
