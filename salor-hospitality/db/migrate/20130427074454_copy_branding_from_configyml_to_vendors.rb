class CopyBrandingFromConfigymlToVendors < ActiveRecord::Migration
  def up
    brandingconf = {
      :codename => 'salorhospitality',
      :title => 'SALOR Hospitality',
      :override_styles => {
        :buttons => {
          :cash => 'cash.png',
          :finish => 'finish.png',
          :finish_and_print => 'finish-and-print.png',
          :user => 'user-arrow.png',
          :tables => 'tables.png',
          :refund => 'refund.png',
          :last_invoice => 'last-invoice.png'
        }
      }
    }
    brandingconfstr = YAML.dump(brandingconf)
    Vendor.update_all  :branding => brandingconfstr
  end

  def down
    Vendor.update_all :branding => "--- {}\n"
  end
end
