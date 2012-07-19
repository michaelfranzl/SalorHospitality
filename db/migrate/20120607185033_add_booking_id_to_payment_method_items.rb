class AddBookingIdToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :booking_id, :integer
  end
end
