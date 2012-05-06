class AddSeparatePrintToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :separate_print, :boolean
  end
end
