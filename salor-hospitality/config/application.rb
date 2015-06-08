# coding: utf-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'socket'
require 'pp'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
require 'escper/escper'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end



  
module SalorHospitality
  
  mattr_accessor :tailor
  mattr_accessor :old_tailors
  mattr_accessor :requestcount
  
  @@tailor = nil
  @@old_tailors = []
  @@requestcount = 0
  
  
  class Application < Rails::Application  
    if ENV['SH_DEBIAN_SITEID']
      SH_DEBIAN_SITEID = ENV['SH_DEBIAN_SITEID']
    else
      SH_DEBIAN_SITEID = 'none'
    end
    if File.exists? '/etc/redhat-release' then
      SH_DEPLOY = 'REDHAT'
      OS_RELEASE = `cat /etc/redhat-release`
    elsif File.exists? '/etc/debian_version' then
      SH_DEPLOY = 'DEBIAN'
      OS_RELEASE = `cat /etc/debian_version`
    elsif File.exists? '/mach_kernel' then
      SH_DEPLOY = 'MAC'
      OS_RELEASE = `uname -r`
    end
    puts "Using database set by environment variable SH_DEBIAN_SITEID (#{SH_DEBIAN_SITEID})"
    
    if File.exists?(File.join(Rails.root, '..', 'debian', 'changelog'))
      changelog = File.open(File.join(Rails.root, '..', 'debian', 'changelog'), 'r').read.split("\n")[0]
      VERSION = "Version " + /.*\((.*)\).*/.match(changelog)[1]
    end
    VERSION ||= `dpkg -s salor-hospitality | grep Version`
    
    
    if File.exists?(File.join('/', 'etc','salor-hospitality', SH_DEBIAN_SITEID, 'config.yml'))
      CONFIGURATION = YAML::load(File.open(File.join('/', 'etc','salor-hospitality', SH_DEBIAN_SITEID, 'config.yml'), 'r').read)
    else
      CONFIGURATION = YAML::load(File.open(File.join(Rails.root, 'config', 'config.yml'), 'r').read)
    end

    LANGUAGES = {
      'en' => 'English',
      'gn' => 'Deutsch',
      'tr' => 'Türkçe',
      'fr' => 'Français',
      'es' => 'Español',
      'pl' => 'Polski',
      'hu' => 'Magyar',
      'el' => 'Greek',
      'ru' => 'Русский',
      'it' => 'Italiana',
      'cn' => 'Chinese',
      'hk' => 'Hongkong',
      'tw' => 'Taiwanese',
      'vi' => 'tiếng Việt',
      'fi' => 'Suomeksi',
      'hr' => 'Hrvatski',
      'nl' => 'Dutch'
    }
    COUNTRIES = {
      'cc' => :default,
      'de' => 'Deutschland',
      'at' => 'Österreich',
      'ch' => 'Schweiz',
      'tr' => 'Türkiye',
      'fr' => 'France',
      'es' => 'España',
      'pl' => 'Polska',
      'hu' => 'Magyarország',
      'el' => 'Ελλάδα',
      'ru' => 'Россия',
      'it' => 'Italia',
      'cn' => '中国',
      'hk' => 'Hongkong',
      'tw' => 'Taiwan',
      'us' => 'USA',
      'gb' => 'England',
      'vi' => 'Việt Nam',
      'kh' => 'ព្រះរាជាណាចក្រកម្ពុជា',
      'fi' => 'Suomi',
      'hr' => 'Hrvatska',
      'nl' => 'Nederland',
      'ng' => "Nigeria"
    }
    COUNTRIES_REGIONS = {
      'cc' => 'en-us',
      'de' => 'gn-de',
      'at' => 'gn-de',
      'ch' => 'gn-ch',
      'tr' => 'tr-tr',
      'fr' => 'fr-fr',
      'es' => 'es-es',
      'pl' => 'pl-pl',
      'hu' => 'hu-hu',
      'el' => 'el-el',
      'ru' => 'ru-ru',
      'it' => 'it-it',
      'cn' => 'cn-cn',
      'us' => 'en-us',
      'gb' => 'en-gb',
      'hk' => 'hk-hk',
      'tw' => 'tw-tw',
      'vi' => 'vi-vi',
      'kh' => 'kh-kh',
      'fi' => 'fi-fi',
      'hr' => 'hr-hr',
      'nl' => 'nl-nl',
      'ng' => 'en-ng',
    }
    COUNTRIES_INVOICES = {
      'cc' => 'cc',
      'de' => 'cc',
      'at' => 'cc',
      'ch' => 'cc',
      'tr' => 'cc',
      'fr' => 'cc',
      'es' => 'cc',
      'pl' => 'pl',
      'hu' => 'cc',
      'el' => 'cc',
      'ru' => 'cc',
      'it' => 'cc',
      'cn' => 'cc',
      'us' => 'cc',
      'gb' => 'cc',
      'hk' => 'cc',
      'tw' => 'cc',
      'vi' => 'cc',
      'kh' => 'cc',
      'fi' => 'cc',
      'hr' => 'cc',
      'nl' => 'cc',
      'ng' => 'cc'
    }
    
    FONTS = Dir.glob(File.join(Rails.root,'public','fonts','*.ttf')).collect{ |f| "#{ /fonts\/(.*).ttf/.match(f)[1]}" }
    PERMISSIONS = [
      'take_orders',
      'reactivate_orders',
      'decrement_items',
      'delete_items',
      'cancel_all_items_in_active_order',
      'finish_orders',
      'order_notes',
      'split_items',
      'move_tables',
      'assign_order_to_user',
      'refund',
      'assign_cost_center',
      'assign_order_to_booking',
      'move_order',
      'interim_receipt',
      'move_order_from_invoice_form',
      'manage_articles',
      'manage_categories',
      'manage_statistic_categories',
      'manage_options',
      'add_option_to_sent_item',
      'finish_all_settlements',
      'finish_own_settlement',
      'view_all_settlements',
      'view_settlements_table',
      'settlement_statistics_taxes',
      'settlement_statistics_taxes_categories',
      'settlement_statistics_sold_quantities',
      'manage_business_invoice',
      'manage_users',
      'manage_taxes',
      'manage_cost_centers',
      'manage_payment_methods',
      'enter_payment_methods',
      'manage_tables',
      'manage_vendors',
      'manage_cameras',
      'counter_mode',
      'immediate_order_finish',
      'see_item_notifications_user_preparation',
      'see_item_notifications_user_delivery',
      'see_item_notifications_vendor_preparation',
      'see_item_notifications_vendor_delivery',
      'see_item_notifications_static',
      'manage_pages',
      'manage_customers',
      'manage_hotel',
      'manage_roles',
      'item_scribe',
      'assign_tables',
      'download_database',
      'download_csv',
      'remote_support',
      'login_locking',
      'mobile_show_tools',
      'receipt_logo',
      'manage_statistics',
      'manage_statistics_hotel',
      'statistics_weekday',
      'statistics_table',
      'statistics_payment_method',
      'statistics_category',
      'statistics_statistic_category',
      'statistics_tax',
      'statistics_sold_quantities',
      'statistics_user',
      'allow_exit',
      'assign_users_to_vendors',
      'manage_advertising',
      'manage_user_logins',
      'see_debug',
    ]
    
    if SalorHospitality::Application::CONFIGURATION[:exception_notification] == true
      require File.join(Rails.root, 'lib', 'exceptions.rb')
      sender_address = SalorHospitality::Application::CONFIGURATION[:exception_notification_sender]
      exception_recipients = SalorHospitality::Application::CONFIGURATION[:exception_notification_receipients]
      config.middleware.use ExceptionNotifier,
          :email_prefix => "[SalorHospitalityException] ",
          :sender_address => sender_address,
          :exception_recipients => exception_recipients,
          :sections => %w(salor request session environment backtrace)
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Vienna'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
