class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  belongs_to :quantity
  has_one :item
  has_and_belongs_to_many :options
  has_and_belongs_to_many :printoptions, :class_name => "Option", :join_table => "items_printoptions"
  validates_presence_of :count, :article_id

  default_scope :order => 'sort DESC'
  
  def real_price
    if price.nil?
      self.quantity ? self.quantity.price : self.article.price
    else
      price
    end
  end

  def optionslist=(optionslist)
    self.options = []
    optionslist.split.each do |o|
      self.options << Option.find(o.to_i)
    end
  end

  def optionslist
    self.options.collect{ |o| "#{ o.id } " }.join
  end

  def printoptionslist=(printoptionslist)
    self.printoptions = []
    printoptionslist.split.each do |o|
      self.printoptions << Option.find(o.to_i)
    end
  end

  def printoptionslist
    self.printoptions.collect{ |o| "#{ o.id } " }.join
  end

  def category
    self.article.category
  end

end
