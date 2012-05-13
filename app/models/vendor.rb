class Vendor < ActiveRecord::Base
  include ActionView::Helpers #::JavaScriptHelper
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
  # u is usage
  # sc is start count
  # pc is printed count
  # catid is category_id
  # i is array of selected option ids
  # t is an object of selected options

  def resources(user,workstation,mobile_special)
    categories = {}
    self.categories.existing.positioned.each do |c|
      articles = {}
      c.articles.existing.active.positioned.reverse.each do |a|
        quantities = {}
        a.quantities.existing.active.positioned.each do |q|
          quantities.merge! q.id => { :ai => a.id, :qi => q.id, :ci => q.article.category.id, :d => "q#{q.id}", :pre => q.prefix, :post => q.postfix, :n => a.name, :p => q.price }
        end
        articles.merge! "#{a.position}#{a.id}" => { :ai => a.id, :ci => a.category.id, :d => "a#{a.id}", :n => a.name, :p => a.price, :q => quantities }
      end
      options = {}
      c.options.existing.each do |o|
        options.merge! o.id => { :id => o.id, :n => o.name, :p => o.price }
      end
      categories.merge! c.id => { :id => c.id, :a => articles, :o => options }
    end

    i18n = {
      :server_no_response => escape_javascript(I18n.t(:server_no_response)),
      :just_order => escape_javascript(I18n.t(:just_order)),
      :enter_price => escape_javascript(I18n.t(:please_enter_price)),
      :enter_comment => escape_javascript(I18n.t(:please_enter_comment)),
      :no_ticket_printing => escape_javascript(I18n.t(:no_printing)),
      :decimal_separator => escape_javascript(I18n.t('number.currency.format.separator')),
      :takeaway => escape_javascript(I18n.t('articles.new.takeaway')),
      :course => escape_javascript(I18n.t('printr.course'))
    }

    permissions = {
      :delete_items => user.role.permissions.include?("delete_items"),
      :decrement_items => user.role.permissions.include?("decrement_items")
    }

    templates = { :item => raw(ActionView::Base.new(File.join(Rails.root,'app','views')).render(:partial => 'items/item_tablerow', :locals => {:workstation => workstation})) }

    settings = {
      :mobile => (not workstation),
      :workstation => workstation,
      :mobile_special => mobile_special,
      :screenlock_timeout => user.screenlock_timeout
    }

    resources = { :c => categories, :permissions => permissions, :i18n => i18n, :templates => templates, :settings => settings }

    return resources.to_json
  end

end
