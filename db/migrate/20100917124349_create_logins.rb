class CreateLogins < ActiveRecord::Migration
  def self.up
    create_table :logins do |t|
      t.string :ip
      t.string :email
      t.string :reverselookup
      t.string :loginname
      t.string :realname
      t.string :referer

      t.timestamps
    end
  end

  def self.down
    drop_table :logins
  end
end
