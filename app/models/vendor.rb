class Vendor < ActiveRecord::Base
  include ActionView::Helpers
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

  def hide
    self.update_attribute :hidden, true
  end

  def image
    return self.images.first.image unless Image.count(:conditions => "imageable_id = #{self.id}") == 0 or self.images.first.nil?
    "/assets/client_logo.png"
  end

  def rlogo_header=(data)
    write_attribute :rlogo_header, Escper::Image.new(data.read, :blob).to_s 
  end

  def rlogo_footer=(data)
    write_attribute :rlogo_footer, Escper::Image.new(data.read, :blob).to_s 
  end

  def get_unique_order_number
    return 0 if not self.use_order_numbers
    if not self.unused_order_numbers.empty?
      # reuse order numbers if present
      nr = self.unused_order_numbers.first
      self.unused_order_numbers.delete(nr)
      self.save
    elsif not self.largest_order_number.zero?
      # increment largest order number
      nr = self.largest_order_number + 1
      self.update_attribute :largest_order_number, nr
    else
      # find Order with largest nr attribute from database. this should happen only once when a new db
      last_order = self.orders.existing.where('nr is not NULL').last
      nr = last_order ? last_order.nr + 1 : 1
    end
    return nr
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
  # sc is start count
  # pc is printed count
  # catid is category_id
  # i is array of selected option ids
  # t is an object of selected options

  def update_cache
    self.update_attribute :resources_cache, self.resources
  end

  def resources
    # the following is speedy, no more nested Ruby/SQL loops
    category_models = self.categories.existing.positioned
    article_models = self.articles.existing.positioned
    quantity_models = self.quantities.existing.positioned
    option_models = self.options.existing.positioned

    quantities = {}
    quantity_models.each do |q|
      ai = q.article_id
      qhash = {"#{q.position}_#{q.id}" => { :ai => ai, :qi => q.id, :ci => q.category_id, :d => "q#{q.id}", :pre => q.prefix, :post => q.postfix, :n => 'dummy article name', :p => q.price }}
      if quantities.has_key?(ai)
        quantities[ai].merge! qhash
      else
        quantities[ai] = qhash
      end
    end

    articles = {}
    article_models.each do |a|
      ci = a.category_id
      ahash = {"#{a.position}_#{a.id}" => { :ai => a.id, :ci => ci, :d => "a#{a.id}", :n => a.name, :p => a.price, :q => quantities[a.id] }}
      if articles.has_key?(ci)
        articles[ci].merge! ahash
      else
        articles[ci] = ahash
      end
    end

    options = {}
    option_models.each do |o|
      o.categories.each do |oc|
        ci = oc.id
        s = o.position.nil? ? 0 : o.position
        ohash = {"#{s}_#{o.id}" => { :id => o.id, :n => o.name, :p => o.price, :s => s }}
        if options.has_key?(ci)
          options[ci].merge! ohash
        else
          options[ci] = ohash
        end
      end
    end

    categories = {}
    category_models.each do |c|
      cid = c.id
      categories[cid] = { :id => cid, :a => articles[cid], :o => options[cid] }
    end

    templates = { :item => raw(ActionView::Base.new(File.join(Rails.root,'app','views')).render(:partial => 'items/item_tablerow')) }

    resources = { :c => categories, :templates => templates }

    return resources.to_json
  end

end
