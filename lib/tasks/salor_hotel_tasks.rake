# desc "Explaining what the task does"
# task :salor_hotel do
#   # Task goes here
# end

namespace :salor_hotel do
  task :seed => :environment do
    radio_surcharge_names = ['Breakfast','Dinner','Full']
    checkbox_surcharge_names = ['Additional Bed']
    common_surcharge_names = ['1 Night', '2 Night']
    surcharge_amounts = [6, 12, 22, -5]

    Company.all.size.times do |c|
      company = Company.all[c]
      puts "========= COMPANY ID #{ company.id } ==========="
      Vendor.where(:company_id => company.id).each do |v|
        puts "Creating Tax #{company.id} #{v.id}"
        local_tax = Tax.create :name => "Local Tax #{company.id} #{v.id}", :percent => 1, :vendor_id => v.id, :company_id => company.id
        room_type_objects = Array.new
        guest_type_objects = Array.new
        4.times do |i|
          puts "Creating RoomType, Room, GuestType #{company.id} #{v.id}"
          rt = SalorHotel::RoomType.create :name => "RoomType #{company.id} #{v.id} #{i}", :vendor_id => v.id, :company_id => company.id
          room_type_objects << rt
          SalorHotel::Room.create :name => "Room#{i}", :room_type_id => rt.id, :vendor_id => v.id, :company_id => company.id
          gt = SalorHotel::GuestType.create :name => "GuestType #{company.id} #{v.id} #{i}", :vendor_id => v.id, :company_id => company.id
          gt.taxes << local_tax if i == 1
          gt.save
          guest_type_objects << gt
        end
        4.times do |i|
          4.times do |j|
            puts "Creating RoomPrice #{company.id} #{v.id} #{i} #{j}"
            SalorHotel::RoomPrice.create :room_type_id => room_type_objects[i].id, :guest_type_id => guest_type_objects[j].id, :base_price => (i + j) * 10, :vendor_id => v.id, :company_id => company.id
          end
        end
        puts "Creating Seasons for #{company.id} #{v.id}"
        s1 = SalorHotel::Season.create :name => 'Summer', :from => Date.parse('2012-06-21'), :to => Date.parse('2012-09-21'), :vendor_id => v.id, :company_id => company.id
        s2 = SalorHotel::Season.create :name => 'Autumn', :from => Date.parse('2012-09-21'), :to => Date.parse('2012-12-21'), :vendor_id => v.id, :company_id => company.id
        s3 = SalorHotel::Season.create :name => 'Winter', :from => Date.parse('2012-12-21'), :to => Date.parse('2012-03-21'), :vendor_id => v.id, :company_id => company.id
        s4 = SalorHotel::Season.create :name => 'Spring', :from => Date.parse('2012-03-21'), :to => Date.parse('2012-06-21'), :vendor_id => v.id, :company_id => company.id
        season_objects = [s1,s2,s3,s4]

        season_objects.size.times do |x|
          guest_type_objects.size.times do |y|
            radio_surcharge_names.size.times do |z|
              surcharge = SalorHotel::Surcharge.create :name => radio_surcharge_names[z], :amount => 1 + x + y + z, :vendor_id => v.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => guest_type_objects[y].id
              surcharge.update_attribute :radio_select, true
            end
            checkbox_surcharge_names.size.times do |z|
              SalorHotel::Surcharge.create :name => checkbox_surcharge_names[z], :amount => x + y + z, :vendor_id => v.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => guest_type_objects[y].id
            end
            common_surcharge_names.size.times do |z|
              SalorHotel::Surcharge.create :name => common_surcharge_names[z], :amount => 3 + x + y + z, :vendor_id => v.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => nil
            end
          end
        end
      end
      puts "========= COMPANY ID #{ company.id } DONE ==========="
    end
  end
end
