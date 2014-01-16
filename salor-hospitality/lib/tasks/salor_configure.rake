# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

desc 'Configures this instance'
# Call like: rake salor_configure['saas']
task :salor_configure, [:mode] => :environment do |t, args|
  
  do_nothing_with_that_variable = History.all # If you remove that line, you'll get  the error message "Expected vendor.rb to define Vendor" when you load this Rake task.
  
  Vendor.existing.each do |v|
    puts "Updating cache of Vendor #{v.id}"
    $Vendor = v
    $Company = v.company
    v.update_cache
    begin
      v.package_upgrade
    rescue
      puts "package upgrade logging failed."
    end
  end
  
#   identifier = ENV['SH_DEBIAN_SITEID'] ? "#{ENV['SH_DEBIAN_SITEID']}" : nil
#   
#   unless Company.where(:identifier => subdomain).any?
#     # this is only useful for local installations where all models are created from the seed script and the Company's subdomain will be nil.
#     puts "No company with subdomain #{subdomain} found. Updating last company that has a subdomain of nil."
#     c = Company.where(:subdomain => nil).last
#     c.update_attributes(:mode => args[:mode], :subdomain => subdomain) if c
#   end
end


