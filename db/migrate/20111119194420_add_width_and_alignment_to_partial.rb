class AddWidthAndAlignmentToPartial < ActiveRecord::Migration
  def self.up
    add_column :partials, :width, :integer
    add_column :partials, :align, :string
  end

  def self.down
    remove_column :partials, :align
    remove_column :partials, :width
  end
end
