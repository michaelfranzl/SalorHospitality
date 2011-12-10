class AddPagesPartialsTable < ActiveRecord::Migration
  def self.up
    create_table :pages_partials, :id => false do |t|
      t.integer  "page_id"
      t.integer  "partial_id"
    end
  end

  def self.down
    drop_table :pages_partials
  end
end
