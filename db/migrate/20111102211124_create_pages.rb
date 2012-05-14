class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.boolean :active, :default => true
      t.boolean :hidden
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
