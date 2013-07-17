class CopyNamesToIdentifiersForVendors < ActiveRecord::Migration
  def up
    i = 0
    Vendor.all.each do |v|
      sanitized_name = v.name.gsub(/[\/\s'"\&\^\$\#\!;\*]/,'_').gsub(/[^\w\/\.\-@]/,'')
      puts "Setting Identifier #{ sanitized_name }#{ i } for Vendor ID #{ v.id }"
      v.update_attribute :identifier, "#{ sanitized_name }#{ i }"
      i += 1
    end
  end

  def down
  end
end
