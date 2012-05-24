class AddScribeEscposToItems < ActiveRecord::Migration
  def change
    add_column :items, :scribe_escpos, :text
  end
end
