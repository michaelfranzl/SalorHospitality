class Vendor < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :company
  has_and_belongs_to_many :users
  has_many :articles
  has_many :categories
  has_many :cost_centers
  has_many :customers
  has_many :groups
  has_many :images, :as => :imageable
  has_many :ingredients
  has_many :items
  has_many :options
  has_many :orders
  has_many :pages
  has_many :partials
  has_many :presentations
  has_many :quantities
  has_many :roles
  has_many :settlements
  has_many :tables
  has_many :roles
  has_many :taxes, :class_name => 'Tax'
  has_many :vendor_printers

  serialize :unused_order_numbers

  validates_presence_of :name

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def image
    return self.images.first.image unless Image.count(:conditions => "imageable_id = #{self.id}") == 0 or self.images.first.nil?
    "/images/client_logo.png"
  end

  # article_id and quantity_id is the model id of Article or Quantity
  # d is the designator, a mix of model and it's id, so that we can have unique values in the HTML, e.g. 'q203' or 'a33'
  # n is the name of either Quantity or Article
  # price is the price of either ...
  # q is a json-sub-object which lists quantities of articles
  # s is position

  # items_json and submit_json returns additional attributes:
  # o is comment
  # count is count
  # x is deleted
  # u is usage
  # sc is start count
  # pc is printed count
  # catid is category_id
  # i is array of selected option ids
  # t is an object of selected options

  def resources
    categories = {}
    self.categories.existing.positioned.each do |c|
      articles = {}
      c.articles.existing.active.positioned.reverse.each do |a|
        quantities = {}
        a.quantities.existing.active.positioned.each do |q|
          quantities.merge! q.id => { :article_id => a.id, :quantity_id => q.id, :catid => q.article.category.id, :d => "q#{q.id}", :pre => q.prefix, :post => q.postfix, :n => a.name, :price => q.price }
        end
        articles.merge! "#{a.position}#{a.id}" => { :article_id => a.id, :catid => a.category.id, :d => "a#{a.id}", :n => a.name, :price => a.price, :q => quantities }
      end
      options = {}
      c.options.existing.each do |o|
        options.merge! o.id => { :id => o.id, :n => o.name, :p => o.price }
      end
      categories.merge! c.id => { :id => c.id, :a => articles, :o => options }
    end
    resources = { :c => categories }
    return resources.to_json
  end

end
