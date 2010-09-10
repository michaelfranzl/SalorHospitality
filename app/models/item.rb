class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  belongs_to :cost_center
  belongs_to :quantity
  has_one :item
  has_and_belongs_to_many :options
  validates_presence_of :count, :article_id

  default_scope :order => 'sort DESC'
  
  def real_price
    if price.nil? or price.zero? then
      self.quantity ? self.quantity.price : self.article.price
    else
      price
    end
  end

  def optionslist=(optionslist)
    self.options = []
    optionslist.split.uniq.each do |o|
      self.options << Option.find(o.to_i)
    end
  end

  def optionslist
    self.options.collect{ |o| "#{ o.id } " }.to_s
  end

  def category
    self.article.category
  end

end
