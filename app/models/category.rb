class Category < ActiveRecord::Base
  belongs_to :tax
  has_many :articles
end
