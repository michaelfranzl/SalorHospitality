class AddColorToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :color, :string
  end
end
