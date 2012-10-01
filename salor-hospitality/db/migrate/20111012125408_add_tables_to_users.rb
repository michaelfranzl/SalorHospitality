class AddTablesToUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      next if u.tables.any?
      u.tables = []
      Table.all.each do |t|
        puts "Adding table #{ t.id } to user #{ u.id }."
        u.tables << t
      end
      u.save
    end
  end

  def self.down
  end
end
