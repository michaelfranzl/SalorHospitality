class DefaultValuesForCustomers < ActiveRecord::Migration
  def up
    change_column :customers, :first_name, :string, :default => ''
    change_column :customers, :last_name, :string, :default => ''
    change_column :customers, :company_name, :string, :default => ''
    change_column :customers, :address, :string, :default => ''
    change_column :customers, :city, :string, :default => ''
    change_column :customers, :state, :string, :default => ''
    change_column :customers, :postalcode, :string, :default => ''
    change_column :customers, :email, :string, :default => ''
    change_column :customers, :telephone, :string, :default => ''
    change_column :customers, :cellphone, :string, :default => ''
    change_column :customers, :country, :string, :default => ''
    Customer.where(:first_name => nil).update_all :first_name => ''
    Customer.where(:last_name => nil).update_all :last_name => ''
    Customer.where(:company_name => nil).update_all :company_name => ''
    Customer.where(:address => nil).update_all :address => ''
    Customer.where(:city => nil).update_all :city => ''
    Customer.where(:state => nil).update_all :state => ''
    Customer.where(:postalcode => nil).update_all :postalcode => ''
    Customer.where(:email => nil).update_all :email => ''
    Customer.where(:telephone => nil).update_all :telephone => ''
    Customer.where(:cellphone => nil).update_all :cellphone => ''
    Customer.where(:country => nil).update_all :country => ''
  end

  def down
  end
end
