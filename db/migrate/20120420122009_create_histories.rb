class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.string :url
      t.integer :user_id
      t.string :action_taken
      t.string :model_type
      t.integer :model_id
      t.string :ip
      t.integer :sensitivity
      t.text :changes_made
      t.text :params

      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
