class CreateSettlements < ActiveRecord::Migration
  def self.up
    create_table :settlements do |t|
      t.float :revenue
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :settlements
  end
end
