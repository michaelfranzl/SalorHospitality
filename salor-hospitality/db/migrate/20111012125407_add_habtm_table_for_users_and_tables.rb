class AddHabtmTableForUsersAndTables < ActiveRecord::Migration
  def self.up
    create_table :tables_users, :id => false do |t|
      t.integer  "table_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :tables_users
  end
end
