# coding: utf-8

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module BillGastro
  class Application < Rails::Application

    mattr_accessor :unused_order_numbers, :largest_order_number

    billgastro_config = File.exist?('config/billgastro-config.yml') ? YAML.load_file( 'config/billgastro-config.yml' ) : {}

    begin
      SERIAL_PRINTER_KITCHEN = SerialPort.new billgastro_config[:printer_kitchen], 9600
    rescue
      SERIAL_PRINTER_KITCHEN = nil
    end

    begin
      SERIAL_PRINTER_BAR = SerialPort.new billgastro_config[:printer_bar], 9600
    rescue
      SERIAL_PRINTER_BAR = nil
    end

    begin
      SERIAL_PRINTER_GUESTROOM = SerialPort.new billgastro_config[:printer_guestroom], 9600
    rescue
      SERIAL_PRINTER_GUESTROOM = nil
    end


    if File.exists? billgastro_config[:printer_kitchen] and File.writable? billgastro_config[:printer_kitchen]
      USB_PRINTER_KITCHEN =  File.open(billgastro_config[:printer_kitchen], 'w:ISO8859-15')
    else
      USB_PRINTER_KITCHEN = nil
    end
    if File.exists? billgastro_config[:printer_bar] and File.writable? billgastro_config[:printer_bar]
      USB_PRINTER_BAR =  File.open(billgastro_config[:printer_bar], 'w:ISO8859-15')
    else
      USB_PRINTER_BAR = nil
    end
    if File.exists? billgastro_config[:printer_guestroom] and File.writable? billgastro_config[:printer_guestroom]
      USB_PRINTER_GUESTROOM =  File.open(billgastro_config[:printer_guestroom], 'w:ISO8859-15')
    else
      USB_PRINTER_GUESTROOM = nil
    end

    INITIAL_CREDITS = 100
    USER_ROLES = { '' => '', 0 => 'Restaurant', 1 => 'Kellner', 2 => 'Admin', 3 => 'Superuser' }
    LANGUAGES = { 'en' => 'English', 'de' => 'Deutsch', 'tr' => 'Türkçe' }

    @@unused_order_numbers = Array.new
    @@largest_order_number = 0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
