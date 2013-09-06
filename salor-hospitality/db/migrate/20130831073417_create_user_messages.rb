class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.integer :sender_id
      t.integer :receipient_id
      t.integer :reply_id
      t.boolean :displayed
      t.string :subject
      t.text :body
      t.string :type
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :hidden
      t.integer :hidden_by
      t.datetime :hidden_at

      t.timestamps
    end
  end
end
