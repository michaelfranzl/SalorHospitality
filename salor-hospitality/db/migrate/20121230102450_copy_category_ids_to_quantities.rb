class CopyCategoryIdsToQuantities < ActiveRecord::Migration
  def up
    Quantity.all.each do |q|
      if q.article
        q.category_id = q.article.category_id
        q.statistic_category_id = q.article.statistic_category_id
        q.save
      end
    end
  end

  def down
  end
end
