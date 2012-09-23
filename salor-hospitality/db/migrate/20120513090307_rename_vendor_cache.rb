class RenameVendorCache < ActiveRecord::Migration
  def up
    rename_column :vendors, :cache, :resources_cache
  end

  def down
    rename_column :vendors, :resources_cache, :cache
  end
end
