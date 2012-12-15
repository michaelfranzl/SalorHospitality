class AddTechnicianEmailToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :technician_email, :string
  end
end
