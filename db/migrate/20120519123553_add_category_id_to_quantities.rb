class AddCategoryIdToQuantities < ActiveRecord::Migration
  def up
    add_column :quantities, :category_id, :integer
    puts "Setting category_id for all Quantities"
    Article.all.each do |a|
      next unless a.quantities.any?
      puts "  Setting category_id #{a.category_id}"
      Quantity.where(:article_id => a.id).update_all :category_id => a.category_id
    end
  end
  def down
    remove_column :quantities, :category_id
  end
end
