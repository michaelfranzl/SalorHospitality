class CopyTaxIdToTaxesForArticles < ActiveRecord::Migration
  def up
    Article.all.each do |a|
      puts "Copying tax for Article #{ a.id }"
      a.taxes = []
      a.taxes << Tax.find_by_id(a.tax_id) if a.tax_id
      a.save
    end
  end

  def down
  end
end
