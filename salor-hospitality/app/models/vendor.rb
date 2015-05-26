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
  has_many :statistic_categories
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
  has_many :receipts
  has_many :cameras
  has_many :histories

  serialize :unused_order_numbers
  serialize :unused_booking_numbers
  serialize :unused_settlement_numbers
  serialize :branding

  validates_presence_of :name
  validate :identifer_present_and_ascii
  validates_uniqueness_of :name, :scope => :hidden
  validates_uniqueness_of :identifier, :scope => :hidden
  validates :update_tables_interval, :numericality => { :greater_than => 17 }
  validates :update_item_lists_interval, :numericality => { :greater_than => 29 }
  validates :update_resources_interval, :numericality => { :greater_than => 101 }
  validates :automatic_printing_interval, :numericality => { :greater_than => 20 }
  validate :public_holidays_formatting_valid
  
  after_commit :sanitize_vendor_printer_paths
  
  before_save :set_hash_id
  

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank
  
    
  def public_holidays_formatting_valid
    return if self.public_holidays.blank?
    
    lines = self.public_holidays.split("\n")
    lines.each do |l|
      stripped_line = l.strip
      next if l.blank?
      if /^\d\d\d\d-\d\d-\d\d$/.match(stripped_line).nil?
        errors.add :public_holidays, I18n.t("activerecord.errors.messages.invalid_iso_date_formatting")
        return
      end
    end
  end
  
  def identifer_present_and_ascii
    if self.identifier.blank?
      errors.add(:identifier, I18n.t('activerecord.errors.messages.empty'))
      return
    end
    
    if self.identifier.length < 4
      errors.add(:identifier, I18n.t('activerecord.errors.messages.too_short', :count => 4))
      return
    end
    
    match = /[a-zA-Z0-9_-]*/.match(self.identifier)[0]
    if match != self.identifier
      errors.add(:identifier, I18n.t('activerecord.errors.messages.must_be_ascii'))
    end
  end
  
  def utc_offset_hours
    # The offset of the Rails application
    Time.zone.now.utc_offset/60/60
  end
  
  def total_utc_offset_hours
    # The additional offset of the store location
    utc_offset_hours +  self.time_offset
  end
  
  def existing_tables
    self.tables.existing
  end
  
  def sanitize_vendor_printer_paths
    self.vendor_printers.existing.update_all :company_id => self.company_id
    self.vendor_printers.existing.each do |vp|
      vp.sanitize_path
    end
  end

  def hide
    self.hidden = true
    self.hidden_at = Time.now
    self.save
  end
  
  def get_region
    SalorHospitality::Application::COUNTRIES_REGIONS[self.country].to_sym
  end

  def logo_image
    return self.image('logo') if Image.where(:imageable_type => 'Vendor', :imageable_id => self.id, :image_type => 'logo').any?
    "/assets/client_logo.png"
  end

  def rlogo_header=(data)
    if data.nil? or data.original_filename.include?('delete')
      write_attribute :rlogo_header, nil
    else
      data.rewind
      write_attribute :rlogo_header, Escper::Img.new(data.read, :blob).to_s 
    end
  end

  def rlogo_footer=(data)
    if data.nil? or data.original_filename.include?('delete')
      write_attribute :rlogo_footer, nil
    else
      data.rewind
      write_attribute :rlogo_footer, Escper::Img.new(data.read, :blob).to_s
    end
  end

  def public_holidays_array
    return nil if self.public_holidays.blank?
    array = self.public_holidays.split("\n").collect do |l|
      l.strip
    end
    array.delete("")
    array.delete(nil)
    return array.sort
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
    category_models       = self.categories.existing.active.positioned
    article_models        = self.articles.existing.active.positioned
    quantity_models       = self.quantities.existing.active.positioned
    option_models         = self.options.existing.positioned
    payment_method_models = self.payment_methods.existing
    table_models          = self.tables.existing
    user_models           = self.company.users.existing
    customer_models       = self.company.customers.existing.active
    
    cstmers = {}
    cstmers[:regulars] = []
    x = 0
    self.customers.existing.active.order("m_points DESC").each do |c|
      if x < 15 then
        cstmers[:regulars] << c.to_hash(self)
      end
      c1 = c.last_name[0,1].downcase
      c2 = c.last_name[0,2].downcase
      cstmers[c1] ||= {}
      cstmers[c1][c2] ||= []
      cstmers[c1][c2] << c.to_hash(self)
      x += 1
    end
    cstmers[:all] = {}
    customer_models.each do |c|
      cuid = c.id
      cstmers[:all][cuid] = {
        :id => cuid,
        :n => c.full_name(true)
      }
    end
    
    quantities = {}
    quantity_models.each do |q|
      ai = q.article_id
      qhash = {
        q.id => {
                 :ai => ai,
                 :qi => q.id,
                 :ci => q.category_id,
                 :d => "q#{q.id}",
                 :sku => q.sku,
                 :pre => q.prefix,
                 :post => q.postfix,
                 :p => q.price
                }
      }
      quantities.merge! qhash
    end

    articles = {}
    article_models.each do |a|
      ci = a.category_id
      aid = a.id
      s = a.position.to_i
      quantity_ids = a.quantities.existing.active.positioned.collect{|q| q.id}
      ahash = {
        a.id => {
                 :ai => aid,
                 :sku => a.sku,
                 :ci => ci,
                 :d => "a#{aid}",
                 :n => a.name,
                 :p => a.price,
                 :q => quantity_ids
                }
      }
      articles.merge! ahash
    end

    options = {}
    option_models.each do |o|
      o.categories.each do |oc|
        ci = oc.id
        s = o.position.to_i
        ohash = {
          o.id => {
                   :id => o.id,
                   :n => o.name,
                   :p => o.price,
                   :s => s
                  }
        }
        options.merge! ohash
      end
    end

    categories = {}
    category_models.each do |c|
      cid = c.id
      s = c.position.to_i
      article_ids = c.articles.existing.active.positioned.collect{ |a| a.id }
      option_ids = c.options.existing.active.positioned.collect{ |o| o.id }
      chash = {
        cid => {
                :id => cid,
                :a => article_ids,
                :o => option_ids,
                :n => c.name
               }
      }
      categories.merge! chash
    end

    payment_methods = {}
    payment_method_models.each do |pm|
      pmid = pm.id
      payment_methods[pm.id] = {
        :id => pmid,
        :n => pm.name,
        :chg => pm.change
      }
    end
    
    tables = {}
    table_models.each do |t|
      tid = t.id
      tables[tid] = {
        :id => tid,
        :n => t.name
      }
    end
    
    users = {}
    user_models.each do |u|
      uid = u.id
      users[uid] = {
        :id => uid,
        :n => u.login,
        :c => u.color
      }
    end

    rooms = Hash.new
    self.rooms.existing.active.each do |r|
      bookings = r.bookings.existing.where(:finished => nil, :paid => nil).each.inject([]) do |ar,b|
        ar.push({
                 :f => b.from_date,
                 :t => b.to_date,
                 :cid => b.customer_id,
                 :d => b.duration
                })
      end
      rooms[r.id] = {
        :n => r.name,
        :rt => r.room_type_id,
        :bks => bookings
      }
    end

    room_types = Hash.new
    self.room_types.existing.active.each { |rt| room_types[rt.id] = { :n => rt.name } }

    room_prices = Hash.new
    self.room_prices.existing.active.each do |rp|
      room_prices[rp.id] = { 
        :rt => rp.room_type_id,
        :gt => rp.guest_type_id,
        :p => rp.base_price,
        :sn => rp.season_id
      }
    end

    guest_types = Hash.new
    self.guest_types.existing.active.each do |gt|
      guest_types[gt.id] = {
        :n => gt.name,
        :t => gt.taxes.collect { |t| t.id }
      }
    end

    surcharges = Hash.new
    self.surcharges.existing.active.each do |sc|
      surcharges[sc.id] = {
        :n => sc.name,
        :a => sc.amount,
        :sn => sc.season_id,
        :gt => sc.guest_type_id,
        :r => sc.radio_select,
        :v => sc.visible,
        :s => sc.selected }
    end

    seasons = Hash.new
    current_season = Season.current(self)
    current_year = Time.now.year
    self.seasons.existing.active.each do |sn|
      seasons[sn.id] = {
        :id => sn.id,
        :is_master => sn.is_master,
        :n => sn.name,
        :f => "#{current_year}-#{sn.from_date.strftime('%m-%d')}",
        :t => "#{current_year}-#{sn.to_date.strftime('%m-%d')}",
        :c => sn == current_season,
        :d => sn.duration,
        :c => sn.color
      }
    end

    taxes = Hash.new
    self.taxes.existing.each { |t| taxes[t.id] = { :n => t.name, :p => t.percent } }

    templates = {
      :item => raw(ActionView::Base.new(File.join(Rails.root,'app','views')).render(:partial => 'items/item_tablerow'))
    }

    resources = {
      :a => articles,
      :q => quantities,
      :o => options,
      :c => categories,
      :templates => templates,
      :customers => cstmers,
      :r => rooms,
      :rt => room_types,
      :rp => room_prices,
      :gt => guest_types,
      :sc => surcharges,
      :sn => seasons,
      :t => taxes,
      :pm => payment_methods,
      :u => users,
      :tb => tables,
      :vp => self.vendor_printers_hash
    }

    return resources.to_json
  end
  
  def vendor_printers_hash
    vendor_printer_models = self.vendor_printers.existing
    vendor_printers = {}
    vendor_printer_models.each do |vp|
      vpid = vp.id
      vendor_printers[vpid] = { :id => vpid, :p => vp.path }
    end
    return vendor_printers
  end
  
  def csv_dump(model, from, to)
    case model
    when 'Item'
      items = self.items.where(:created_at => from..to)
      attributes = "id;hidden;hidden_at;hidden_by;order.nr;created_at;updated_at;order.table.name;order.user.login;order.nr;label;category.name;count;max_count;min_count;price_with_options;article.taxes.first.percent;tax_sum;refunded;refund_sum;refunded_by;settlement.nr;cost_center_id;"
      output = ''
      output += "#{attributes}\n"
      output += Vendor.to_csv(items, Item, attributes)
    else
      output = nil
    end
    return output
  end

  def fisc_dump(from, to, location)
    tmppath = SalorHospitality::Application.config.paths['tmp'].first
    
    label = "salor-hospitality-fiscal-backup-#{ I18n.l(Time.now, :format => :datetime_iso2) }"
    dumppath = File.join(tmppath, label)
    FileUtils.mkdir_p(dumppath)
      
    # DUMP DATABASE
    dbconfig = YAML::load(File.open(SalorHospitality::Application.config.paths['config/database'].first))
    sqldump_in_tmp = File.join(tmppath, 'database.sql')
    mode = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
    username = dbconfig[mode]['username']
    password = dbconfig[mode]['password']
    database = dbconfig[mode]['database']
    `mysqldump -u #{username} -p#{password} #{database} > #{dumppath}/database.sql`

    
    # DUMP LOGFILE
    logfile = SalorHospitality::Application.config.paths['log'].first
    logfile_basename = File.basename(logfile)
    logfile_in_tmp = File.join(tmppath, logfile_basename)
    FileUtils.cp(logfile, dumppath)
    

    # GENERATE CSV FILES
    self.dump_all(from, to, dumppath)
    
    # ZIP IT UP
    zip_outfile = "#{ location }/#{ label }.zip"
    Dir.chdir(dumppath)
    `zip -r #{ zip_outfile } .`
    `chmod 777 #{ zip_outfile }`
    
    FileUtils.rm_r dumppath # causes exception
    
    return zip_outfile
  end
  
  def package_upgrade
    lines = `zcat /usr/share/doc/salor-hospitality/changelog.gz`.split("\n")
    puts "Currently installed version is #{lines.first}"
    
    last_upgrade_history = self.histories.where(:action_taken => "package_upgrade").last
    
    if last_upgrade_history
      last_version = last_upgrade_history.changes_made
      puts "Last version was #{ last_version }"
      
      match = /\((.*?)\)/.match(lines[0])
      version = match[1] if match

      difflines = []
      lines.each do |l|
        break if l == last_version
        difflines << l if l.include?('*')
      end
      
      vendor_printers = self.vendor_printers.existing
      if vendor_printers.any?
        puts "Printing system change report in accordance to financial regulations"
        output = "\e@" +      # initialize printer
            "\e!\x38" +       # big font
            "UPDATE\n" +
            I18n.l(Time.now, :format => :datetime_iso2) +
            "\nVERSION #{ version.to_s }\n\n" +
            "\e!\x01" +            # smallest font
            difflines.join("\n") + # changelog output
            "\n\n\n\n\n" +         # space
            "\x1DV\x00\x0C"        # paper cut
        print_engine = Escper::Printer.new(self.company.mode, vendor_printers, File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, self.hash_id))
        print_engine.open
        bytes_written, content_sent = print_engine.print(vendor_printers.first.id, output)
        bytes_sent = content_sent.length
        Receipt.create :vendor_id => self.id,
            :company_id => self.company_id,
            :vendor_printer_id => vendor_printers.first.id,
            :content => output,
            :bytes_sent => bytes_sent,
            :bytes_written => bytes_written
        print_engine.close
      end
    end
    
    h = self.histories.new
    h.company_id = h.company_id
    h.action_taken = "package_upgrade"
    h.changes_made = lines.first
    h.save
    puts "Created History record for package upgrade"
  end
  
  def offset
    self.id - self.company.vendors.existing.first.id
  end
  
  def region
    SalorHospitality::Application::COUNTRIES_REGIONS[self.country]
  end
  
  def identifier
    ident = read_attribute :identifier
    hid = "identifier_unset" if ident.blank?
    return ident
  end
  
  def hash_id
    hid = read_attribute :hash_id
    hid = "hash_id_unset" if hid.blank?
    return hid
  end
  
  def set_hash_id
    hid = read_attribute :hash_id
    unless hid.blank?
      ActiveRecord::Base.logger.info "hash_id is already set."
      return
    end
    self.hash_id = "#{ self.identifier }#{ generate_random_string[0..20] }"
    ActiveRecord::Base.logger.info "Set hash_id to #{ self.hash_id }."
  end
  
  def dump_all(from, to, device)
    tfrom = from.strftime("%Y%m%d")
    tto = to.strftime("%Y%m%d")
    
    items = self.items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;count;article_id;order_id;created_at;updated_at;quantity_id;price;max_count;min_count;user_id;hidden;hidden_at;hidden_by;category_id;tax_sum;refunded;refund_sum;refunded_by;settlement_id;cost_center_id;taxes"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(items, Item, attributes)
    end
    
    booking_items = self.booking_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityBookingItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;booking_id;guest_type_id;sum;created_at;updated_at;count;base_price;refund_sum;taxes;from_date;to_date;season_id;duration;booking_item_id;ui_parent_id;ui_id;unit_sum;room_id;date_locked;tax_sum;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(booking_items, BookingItem, attributes)
    end
    
    surcharge_items = self.surcharge_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalitySurchargeItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;surcharge_id;booking_item_id;amount;season_id;guest_type_id;taxes;sum;duration;count;from_date;to_date;tax_sum;booking_id;hidden;hidden_at;hidden_by;created_at;updated_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(surcharge_items, SurchargeItem, attributes)
    end
    
    bookings = self.bookings.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityBookings#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;from_date;to_date;customer_id;sum;paid;note;created_at;updated_at;room_id;finished;user_id;refund_sum;nr;change_given;duration;taxes;booking_item_sum;finished_at;paid_at;tax_sum;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(bookings, Booking, attributes)
    end
    
    orders = self.orders.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityOrders#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;finished;table_id;user_id;settlement_id;created_at;updated_at;sum;cost_center_id;printed_from;nr;tax_id;refund_sum;note;customer_id;hidden;hidden_at;hidden_by;printed;paid;booking_id;taxes;finished_at;paid_at;reactivated;reactivated_by;reactivated_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(orders, Order, attributes)
    end
    
    taxes = self.taxes
    File.open("#{device}/SalorHospitalityTaxes#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;percent;name;created_at;updated_at;letter;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(taxes, Tax, attributes)
    end
    
    option_items = self.option_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityOptionItem#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;option_id;item_id;order_id;price;name;count;sum;created_at;updated_at;no_ticket;separate_ticket;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(option_items, OptionItem, attributes)
    end
    
    tax_items = self.tax_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityTaxItem#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;tax_id;item_id;booking_item_id;order_id;booking_id;settlement_id;gro;net;tax;created_at;updated_at;letter;surcharge_item_id;name;percent;hidden;hidden_by;hidden_at;refunded;cost_center_id;category_id"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(tax_items, TaxItem, attributes)
    end
    
    pmis = self.payment_method_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityPaymentMethodItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;payment_method_id;order_id;amount;created_at;updated_at;booking_id;refunded;cash;refund_item_id;settlement_id;cost_center_id;change;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(pmis, PaymentMethodItem, attributes)
    end
    
    settlements = self.settlements.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalitySettlements#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;nr;revenue;user_id;created_at;updated_at;finished;initial_cash;sum;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(settlements, Settlement, attributes)
    end
    
    options = self.options
    File.open("#{device}/SalorHospitalityOptions#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;price;created_at;updated_at;hidden;hidden_by;hidden_at;active;separate_ticket;no_ticket"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(options, Option, attributes)
    end
    
    articles = self.articles
    File.open("#{device}/SalorHospitalityArticles#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;description;category_id;price;active;created_at;updated_at;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(articles, Article, attributes)
    end
    
    quantities = self.quantities
    File.open("#{device}/SalorHospitalityQuantities#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;prefix;postfix;price;article_id;created_at;updated_at;active;hidden;hidden_by;hidden_at;category_id;article_name"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(quantities, Quantity, attributes)
    end
    
    users = self.users
    File.open("#{device}/SalorHospitalityUsers#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;login;title;created_at;updated_at;role_id;active;hidden;hidden_at;hidden_by;last_active_at;last_login_at;last_logout_at;email"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(users, User, attributes)
    end
    
    cost_centers = self.cost_centers
    File.open("#{device}/SalorHospitalityCostCenters#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;description;created_at;updated_at;hidden;hidden_by;hidden_at;no_payment_methods"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(cost_centers, CostCenter, attributes)
    end
    
    
    payment_methods = self.payment_methods
    File.open("#{device}/SalorHospitalityPaymentMethods#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;created_at;updated_at;hidden;hidden_by;hidden_at;cash;change"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(payment_methods, PaymentMethod, attributes)
    end
    
    
    histories = self.histories.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityHistories#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;url;user_id;action_taken;model_type;model_id;ip;changes_made;params;created_at;updated_at"
      f.write("#{attributes}\n")
      f.write Vendor.to_csv(histories, History, attributes)
    end
    
    receipts = self.receipts.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityReceipts#{tfrom}-#{tto}.txt","w:ASCII-8BIT") do |f|
      receipts.each do |r|
        string = "\n\nReceipt id:%i, user_id:%i, vendor_printer_id:%i, order_id:%i, order_nr:%i, created_at:%s\n\n" % [r.id, r.user_id.to_i, r.vendor_printer_id.to_i, r.order_id.to_i, r.order_nr.to_i, r.created_at]
        f.write string
        f.write r.content.gsub("\e@\e!8\n", "").gsub("\x1DV\x00\ep\x00\x99\x99\f".force_encoding('ASCII-8BIT'), "")
      end
    end
    
    # Missing models for report, but not critical: Room, RoomType, RoomPrice, GuestType, Surcharge, Season
  end
  
  private
  
  def Vendor.to_csv(objects, klass, attributes)
    attrs = attributes.split(";")
    formatstring = ""
    attrs.each do |a|
      #puts "ATTR #{ klass.to_s}: #{ a }"
      cls = klass.columns_hash[a].type if klass.columns_hash[a]
      case cls
      when :integer
        formatstring += "%i;"
      when :datetime, :string, :boolean, :text
        formatstring += "%s;"
      when :float
        formatstring += "%.2f;"
      else
        formatstring += "%s;"
      end
    end
    lines = []
    objects.each do |item|
      values = []
      attrs.size.times do |j|
        val = attrs[j].split('.').inject(item) do |klass, method|
          klass.send(method) unless klass.nil?
        end
        val = 0 if val.nil?
        values << val
      end
      lines << sprintf(formatstring, *values)
    end
    
    return lines.join("\n")
  end
  
  def generate_random_string
    collection = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
    (0...128).map{ collection[rand(collection.length)] }.join
  end
end
