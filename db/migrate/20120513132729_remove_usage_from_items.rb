class RemoveUsageFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :usage
    remove_column :articles, :usage
    remove_column :quantities, :usage
    add_column :options, :no_ticket, :boolean
  end
end
