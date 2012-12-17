class AddUrlSnapshotToCameras < ActiveRecord::Migration
  def change
    add_column :cameras, :url_snapshot, :string
    rename_column :cameras, :url, :url_stream
  end
end
