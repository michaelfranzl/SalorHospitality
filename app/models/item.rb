class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  belongs_to :cost_center
  validates_presence_of :count, :article_id

  default_scope :order => 'sort ASC'

end
