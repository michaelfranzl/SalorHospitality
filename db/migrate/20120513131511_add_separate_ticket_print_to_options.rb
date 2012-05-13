class AddSeparateTicketPrintToOptions < ActiveRecord::Migration
  def change
    add_column :options, :separate_ticket, :boolean
  end
end
