class CreateStatisticCategories < ActiveRecord::Migration
  def change
    create_table :statistic_categories do |t|
      t.string :name
      t.boolean :hidden
      t.integer :company_id
      t.integer :vendor_id

      t.timestamps
    end
  end
end
