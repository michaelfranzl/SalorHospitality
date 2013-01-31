class AddIdentifierToCompany < ActiveRecord::Migration
  def up
    if not column_exists?('companies', 'identifier')
      add_column :companies, :identifier, :string
    end
  end

  def down
    remove_column :companies, :identifier
  end
end
