class ItemType < ActiveRecord::Base
  include Scope
  include Base
  
  belongs_to :vendor
  belongs_to :company
  
  has_many :articles
  has_many :items
end
