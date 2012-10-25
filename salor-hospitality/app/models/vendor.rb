# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
  has_many :rooms
  has_many :room_types
  has_many :guest_types
  has_many :seasons
  has_many :surcharges
  has_many :room_prices
  has_many :bookings
  has_many :booking_items
  has_many :payment_methods
  has_many :payment_method_items
  has_many :surcharge_items
  has_many :tax_amounts
  has_many :tax_items
  has_many :option_items

  serialize :unused_order_numbers
  serialize :unused_booking_numbers

  validates_presence_of :name

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def hide
    self.update_attribute :hidden, true
  end
  
  def region
    SalorHospitality::Application::COUNTRIES_REGIONS[self.country]
  end

  def logo_image
    return self.image('logo') unless Image.count(:conditions => "imageable_id = #{self.id}") == 0 or self.images.first.nil?
    "/assets/client_logo.png"
  end

  def rlogo_header=(data)
    if data.nil?
      write_attribute :rlogo_header, nil
    else
      write_attribute :rlogo_header, Escper::Image.new(data.read, :blob).to_s 
    end
  end

  def rlogo_footer=(data)
    if data.nil?
      write_attribute :rlogo_footer, nil
    else
      write_attribute :rlogo_footer, Escper::Image.new(data.read, :blob).to_s
    end
  end

  def get_unique_model_number(model_name_singular)
    model_name_plural = model_name_singular + 's'
    return 0 if not self.send("use_#{model_name_singular}_numbers")
    if not self.send("unused_#{model_name_singular}_numbers").empty?
      # reuse order numbers if present'
      nr = self.send("unused_#{model_name_singular}_numbers").first
      self.send("unused_#{model_name_singular}_numbers").delete(nr)
      self.save
    elsif not self.send("largest_#{model_name_singular}_number").zero?
      # increment largest model number'
      nr = self.send("largest_#{model_name_singular}_number") + 1
      self.update_attribute "largest_#{model_name_singular}_number", nr
    else
      # find Order with largest nr attribute from database. this should happen only once when a new db'
      last_model = self.send(model_name_plural).existing.where('nr is not NULL OR nr <> 0').last
      nr = last_model ? last_model.nr + 1 : 1
      self.update_attribute "largest_#{model_name_singular}_number", nr
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
    cstmers = {}
    cstmers[:regulars] = []
    x = 0
    self.customers.order("m_points DESC").each do |c|
      if x < 15 then
        cstmers[:regulars] << c.to_hash
      end
      c1 = c.last_name[0,1].downcase
      c2 = c.last_name[0,2].downcase
      cstmers[c1] ||= {}
      cstmers[c1][c2] ||= []
      cstmers[c1][c2] << c.to_hash
      x += 1
    end
    # the following is speedy, no more nested Ruby/SQL loops
    category_models       = self.categories.existing.active.positioned
    article_models        = self.articles.existing.active.positioned
    quantity_models       = self.quantities.existing.active.positioned
    option_models         = self.options.existing.positioned
    payment_method_models = self.payment_methods.existing
    table_models          = self.tables.existing
    user_models           = self.users.existing

    quantities = {}
    quantity_models.each do |q|
      ai = q.article_id
      qhash = {"#{q.position}_#{q.id}" => { :ai => ai, :qi => q.id, :ci => q.category_id, :d => "q#{q.id}", :pre => q.prefix, :post => q.postfix, :p => q.price }}
      if quantities.has_key?(ai)
        quantities[ai].merge! qhash
      else
        quantities[ai] = qhash
      end
    end

    articles = {}
    article_models.each do |a|
      ci = a.category_id
      quantities_modified = {}
      if quantities.has_key?(a.id)
        quantities[a.id].each_key do |key|
          quantities[a.id][key][:n] = a.name
        end
      end
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
      categories[cid] = { :id => cid, :a => articles[cid], :o => options[cid], :n => c.name }
    end

    payment_methods = {}
    payment_method_models.each do |pm|
      pmid = pm.id
      payment_methods[pm.id] = { :id => pmid, :n => pm.name, :chg => pm.change }
    end
    
    tables = {}
    table_models.each do |t|
      tid = t.id
      tables[tid] = { :id => tid, :n => t.name }
    end
    
    users = {}
    user_models.each do |u|
      uid = u.id
      users[uid] = { :id => uid, :n => u.login }
    end

    rooms = Hash.new
    self.rooms.existing.active.each { |r| rooms[r.id] = { :n => r.name, :rt => r.room_type_id, :bks => r.bookings.existing.where(:finished => nil, :paid => nil).each.inject([]) {|ar,b| ar.push({:f => b.from_date, :t => b.to_date, :cid => b.customer_id, :d => b.duration } ) } } }

    room_types = Hash.new
    self.room_types.existing.active.each { |rt| room_types[rt.id] = { :n => rt.name } }

    room_prices = Hash.new
    self.room_prices.existing.active.each { |rp| room_prices[rp.id] = { :rt => rp.room_type_id, :gt => rp.guest_type_id, :p => rp.base_price, :sn => rp.season_id } }

    guest_types = Hash.new
    self.guest_types.existing.active.each { |gt| guest_types[gt.id] = { :n => gt.name, :t => gt.taxes.collect{ |t| t.id } }}

    surcharges = Hash.new
    self.surcharges.existing.active.each { |sc| surcharges[sc.id] = { :n => sc.name, :a => sc.amount, :sn => sc.season_id, :gt => sc.guest_type_id, :r => sc.radio_select, :v => sc.visible, :s => sc.selected } }

    seasons = Hash.new
    current_season = Season.current(self)
    current_year = Time.now.year
    self.seasons.existing.active.each { |sn| seasons[sn.id] = { :n => sn.name, :f => "#{current_year}-#{sn.from_date.strftime('%m-%d')}", :t => "#{current_year}-#{sn.to_date.strftime('%m-%d')}", :c => sn == current_season, :d => sn.duration } }

    taxes = Hash.new
    self.taxes.existing.each { |t| taxes[t.id] = { :n => t.name, :p => t.percent } }

    templates = { :item => raw(ActionView::Base.new(File.join(Rails.root,'app','views')).render(:partial => 'items/item_tablerow')) }

    resources = { :c => categories, :templates => templates, :customers => cstmers, :r => rooms, :rt => room_types, :rp => room_prices, :gt => guest_types, :sc => surcharges, :sn => seasons, :t => taxes, :pm => payment_methods, :u => users, :tb => tables }

    return resources.to_json
  end

end
