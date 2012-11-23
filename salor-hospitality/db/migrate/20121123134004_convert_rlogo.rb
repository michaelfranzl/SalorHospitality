class ConvertRlogo < ActiveRecord::Migration
  def up
    change_column :vendors, :rlogo_header, :binary
  end

  def down
    change_column :vendors, :rlogo_header, :text
  end
end
