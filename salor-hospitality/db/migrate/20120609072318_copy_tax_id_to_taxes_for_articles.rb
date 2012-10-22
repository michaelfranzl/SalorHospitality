class CopyTaxIdToTaxesForArticles < ActiveRecord::Migration
  def up
    begin
      create_table :articles_taxes, :id => false do |t|
        t.integer :tax_id
        t.integer :article_id
      end
    rescue
      puts "Table Already Existed."
    end
    Article.all.each do |a|
      puts "Copying tax for Article #{ a.id }"
      a.taxes = []
      tax = Tax.find_by_id(a.category.tax_id) if a.category
      tax = Tax.find_by_id(a.tax_id) if a.tax_id
      a.taxes << tax unless tax.nil?
      a.save
    end
  end

  def down
    drop_table :articles_taxes
  end
end
