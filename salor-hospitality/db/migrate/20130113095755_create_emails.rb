class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :sender
      t.string :receiptient
      t.string :subject
      t.text :body
      t.boolean :technician
      t.integer :vendor_id
      t.integer :company_id
      t.integer :user_id
      t.integer :order_id
      t.integer :settlement_id

      t.timestamps
    end
  end
end
