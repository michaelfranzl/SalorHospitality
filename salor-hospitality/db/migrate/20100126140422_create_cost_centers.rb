class CreateCostCenters < ActiveRecord::Migration
  def self.up
    create_table :cost_centers do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :cost_centers
  end
end
