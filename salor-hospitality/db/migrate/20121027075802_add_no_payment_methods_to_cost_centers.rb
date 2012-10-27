class AddNoPaymentMethodsToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :no_payment_methods, :boolean, :default => false
  end
end
