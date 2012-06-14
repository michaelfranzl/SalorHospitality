namespace :salor_hotel do
  task :seed => :environment do
    surcharge_names = ['Breakfast','Dinner','Pension','Additional bed']
    surcharge_amounts = [6, 12, 22, -5]

    Company.all.each do |c|
      c.vendors.all.each do |v|
        puts "Creating Tax #{c.id} #{v.id}"
        local_tax = Tax.create :name => "Local Tax #{c.id} #{v.id}", :percent => 1, :vendor => v, :company => c
        room_type_objects = Array.new
        guest_type_objects = Array.new
        4.times do |i|
          puts "Creating RoomType, Room, GuestType #{c.id} #{v.id}"
          rt = RoomType.create :name => "RoomClass #{c.id} #{v.id} #{i}", :vendor => v, :company => c
          room_type_objects << rt
          Room.create :name => "Room#{i}", :room_type_id => rt.id, :vendor => v, :company => c
          gt = GuestType.create :name => "GuestType #{c.id} #{v.id} #{i}", :vendor => v, :company => c
          gt.taxes << local_tax if i == 1
          gt.save
          guest_type_objects << gt
        end
        4.times do |i|
          4.times do |j|
            puts "Creating RoomPrice #{c.id} #{v.id} #{i} #{j}"
            RoomPrice.create :room_type_id => room_type_objects[i].id, :guest_type_id => guest_type_objects[j].id, :base_price => (i + j) * 10, :vendor => v, :company => c
          end
        end
        puts "Creating Seasons for #{c.id} #{v.id}"
        s1 = Season.create :name => 'Summer', :from => Date.parse('2012-06-21'), :to => Date.parse('2012-09-21'), :vendor => v, :company => c
        s2 = Season.create :name => 'Autumn', :from => Date.parse('2012-09-21'), :to => Date.parse('2012-12-21'), :vendor => v, :company => c
        s3 = Season.create :name => 'Winter', :from => Date.parse('2012-12-21'), :to => Date.parse('2012-03-21'), :vendor => v, :company => c
        s4 = Season.create :name => 'Spring', :from => Date.parse('2012-03-21'), :to => Date.parse('2012-06-21'), :vendor => v, :company => c
        season_objects = [s1,s2,s3,s4]
        surcharge_names.size.times do |i|
          season_objects.size.times do |j|
            Surcharge.create :name => surcharge_names[i], :amount => surcharge_amounts[i], :vendor => v, :company => c, :season_id => season_objects[j].id, :guest_type_id => "#{ rand(2) == 0 ? guest_type_objects[rand(guest_type_objects.size)].id : nil }"
          end
        end
      end
    end
  end
end
