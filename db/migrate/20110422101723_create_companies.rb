class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name, :default => 'Bill Gastro'
      t.string :subdomain, :default => 'demo'

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
