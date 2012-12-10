class CreateCameras < ActiveRecord::Migration
  def change
    create_table :cameras do |t|
      t.string :name
      t.string :host_internal
      t.string :host_external
      t.string :port
      t.string :url
      t.string :description
      t.boolean :active, :default => true
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :hidden
      t.integer :hidden_by
      t.datetime :hidden_at

      t.timestamps
    end
  end
end
