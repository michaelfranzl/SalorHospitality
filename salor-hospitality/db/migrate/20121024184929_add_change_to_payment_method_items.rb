class AddChangeToPaymentMethodItems < ActiveRecord::Migration
  def up
    add_column :payment_method_items, :change, :boolean, :default => false
    add_column :payment_methods, :change, :boolean, :default => false
    change_column :payment_method_items, :cash, :boolean, :default => false
    change_column :payment_methods, :cash, :boolean, :default => false
    PaymentMethodItem.where(:cash => nil).update_all :cash => false
    PaymentMethod.where(:cash => nil).update_all :cash => false
  end
  def down
    remove_column :payment_method_items, :change
    remove_column :payment_methods, :change
    change_column :payment_method_items, :cash, :boolean
    change_column :payment_methods, :cash, :boolean
  end
end
