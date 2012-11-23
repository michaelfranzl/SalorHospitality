class ChangeToBinaryFields < ActiveRecord::Migration
  def up
    change_column :vendors, :rlogo_footer, :binary
    change_column :items, :scribe_escpos, :binary
  end

  def down
    change_column :vendors, :rlogo_footer, :text
    change_column :items, :scribe_escpos, :text
  end
end
