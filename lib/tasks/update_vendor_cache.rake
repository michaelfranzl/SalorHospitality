desc 'Updates the vendor cache'

task :update_vendor_cache => :environment do
  Vendor.all.each do |v|
    puts "Updating cache of Vendor #{v.id}"
    v.update_cache
  end
end
