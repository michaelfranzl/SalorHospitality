class AddUsersVendorsTable < ActiveRecord::Migration
  def self.up
    create_table :users_vendors, :id => false do |t|
      t.references :user
      t.references :vendor
    end
  end

  def self.down
    drop_table :users_vendors
  end
end
