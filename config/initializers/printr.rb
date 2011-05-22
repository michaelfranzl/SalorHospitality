Printr.setup do |config|
config.printr_source = { :active_record => { 
  :class_name => VendorPrinter, 
  :name => :name, 
  :path => :path } 
}
end
