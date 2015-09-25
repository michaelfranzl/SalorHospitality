class CreatePlugins < ActiveRecord::Migration
  def change
    create_table :plugins do |t|
      t.string :name
      t.string :filename
      t.string :base_path
      t.text :files
      t.text :meta
      t.integer :company_id
      t.integer :vendor_id
      t.integer :user_id
      t.boolean :hidden
      t.integer :hidden_by
      t.datetime :hidden_at

      t.timestamps
    end
  end
end
