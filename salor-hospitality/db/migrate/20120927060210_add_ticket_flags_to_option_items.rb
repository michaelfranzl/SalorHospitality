class AddTicketFlagsToOptionItems < ActiveRecord::Migration
  def change
    add_column :option_items, :no_ticket, :boolean
    add_column :option_items, :separate_ticket, :boolean
  end
end
