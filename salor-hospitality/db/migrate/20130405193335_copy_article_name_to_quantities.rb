class CopyArticleNameToQuantities < ActiveRecord::Migration
  def up
    Quantity.all.each do |q|
      next unless q.article
      puts "Copying artile name #{ q.article.name } to quantity #{ q.id }"
      q.article_name = q.article.name
      q.save
    end
  end

  def down
  end
end
