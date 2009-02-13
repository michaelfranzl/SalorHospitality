class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :tables do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tables
  end
end
