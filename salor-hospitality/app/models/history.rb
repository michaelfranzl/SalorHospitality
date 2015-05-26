# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class History < ActiveRecord::Base
  include Scope
  belongs_to :user
  belongs_to :model, :polymorphic => true
  belongs_to :company
  belongs_to :vendor
  
  def changes_made=(changes)
    if changes.class == Hash
      write_attribute :changes_made, changes.to_yaml
    elsif changes.class == String
      write_attribute :changes_made, changes.to_s
    end
  end
  
  def escpos
    output = "\e@" +
        "\e!\x38" +       # big font
        "UPDATE\n#{ self.model.class.to_s } ID #{ self.model.id }\n" +
        I18n.l(Time.now, :format => :datetime_iso2) +
        "\e!\x00" +        # normal font
        "\n\n" +
        "#{ self.user.login }@#{ self.ip }" +
        "\n\n"
    
    output += self.changes_made
    
    output += "\n\n\n\n\n\n\n" +         # space
          "\x1DV\x00\x0C"            # paper cut
    return output
  end
  
  def print
    return if self.vendor.nil? or self.vendor.history_print != true
    
    data = self.escpos
    vendor_printers = self.vendor.vendor_printers.existing
    
    print_engine = Escper::Printer.new self.company.mode,
        vendor_printers,
        File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, self.vendor.hash_id)
    print_engine.open
    bytes_written, content_sent = print_engine.print(vendor_printers.first.id, data)
    print_engine.close
    
    if SalorHospitality::Application::CONFIGURATION[:receipt_history] == true
      r = Receipt.new
      r.user_id = self.user_id
      r.content = data
      r.vendor_id = self.vendor_id
      r.company_id = self.company_id
      r.vendor_printer_id = vendor_printers.first.id
      r.bytes_sent = content_sent.length
      r.bytes_written = bytes_written
      r.save
    end
    
    return data
  end
end
