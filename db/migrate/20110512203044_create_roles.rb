class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.string :permissions, :default => [], :limit => 1000

      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
