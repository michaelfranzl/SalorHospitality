class AddPositionToOptions < ActiveRecord::Migration
  def self.up
    add_column :options, :position, :integer
  end

  def self.down
    remove_column :options, :position
  end
end
