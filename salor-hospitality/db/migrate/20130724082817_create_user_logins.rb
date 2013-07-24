class CreateUserLogins < ActiveRecord::Migration
  def change
    create_table :user_logins do |t|
      t.integer :company_id
      t.integer :vendor_id
      t.integer :user_id
      t.datetime :login
      t.datetime :logout
      t.integer :duration
      t.float :hourly_rate
      t.boolean :hidden
      t.integer :hidden_by
      t.datetime :hidden_at
      t.string :ip
      t.boolean :auto_logout

      t.timestamps
    end
  end
end
