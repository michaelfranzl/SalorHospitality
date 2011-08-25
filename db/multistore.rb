# There will need to be a few Global Variables
# $USER => The currently logged in User
# $COMPANY => The currently select Company

# Create Some Users

User.delete_all

owner1 = User.new ( {
    :login => 'owner1',
    :password => 'owner1',
    :title => 'Owner One',
    :language => 'en',
    :is_owner => true
} )
owner1.save
puts "# #{owner1.id} created, is_owner = #{owner1.is_owner}"
owner2 = User.new ( {
    :login => 'owner2',
    :password => 'owner2',
    :title => 'Owner Two',
    :language => 'en',
    :is_owner => true
} )
owner2.save
puts "# #{owner2.id} created, is_owner = #{owner2.is_owner}"
puts "# Create some companies"
Company.delete_all
c1 = Company.new( {
    :name => "Company One",
    :user_id => owner1.id
} )
c1.save
c2 = Company.new( {
    :name => "Company Two",
    :user_id => owner1.id
} )
c2.save

c3 = Company.new( {
    :name => "Company Three",
    :user_id => owner2.id
} )
c3.save


puts "# There are #{Company.count} companies."
owner1.reload
owner2.reload
puts "# #{owner1.id} has #{owner1.companies.count} companies"
puts "# #{owner2.id} has #{owner2.companies.count} companies"
$USER = owner1 # $USER needs to be a gloabl variable
$COMPANY = c1
puts "# $USER is #{$USER.id}"
puts "# Creating some employees"
emp1 = User.new( {
    :login => 'emp1',
    :password => 'emp1',
    :title => 'Employee One',
    :language => 'en',
    :is_owner => false
} )
emp2 = User.new( {
    :login => 'emp2',
    :password => 'emp2',
    :title => 'Employee Two',
    :language => 'en',
    :is_owner => false
} )
emp3 = User.new( {
    :login => 'emp3',
    :password => 'emp3',
    :title => 'Employee Three',
    :language => 'en',
    :is_owner => false
} )
emp1.set_model_owner
emp2.set_model_owner
emp3.set_model_owner(owner2) # i.e. we can create employees outside of the current $USER
emp1.save
emp2.save
emp3.save
puts "# #{$USER.id} has #{$USER.employees.count} employees"
puts "# #{emp3.get_owner.id} has #{emp3.get_owner.employees.count} employees"
puts "# Employee #{emp1.id} is owned by #{emp1.get_owner.id}"
puts "# Employee #{emp3.id} is owned by #{emp3.get_owner.id}"
puts "# Creating some Taxes"
Tax.delete_all
t1 = Tax.new( { 
    :name => "C1 Tax 1",
    :percent => 7.56
} )
t1.set_model_owner
t1.save
# and for c2

t2 = Tax.new( { 
    :name => "C2 Tax 1",
    :percent => 7.56
} )
t2.set_model_owner(nil,c2) # i.e. we can attach it to a store out of context of $COMPANY
t2.save

# and for c3

t3 = Tax.new( { 
    :name => "C1 Tax 1",
    :percent => 7.56
} )
t3.set_model_owner(owner2,c3)
t3.save

puts "# There are #{Tax.count} taxes"
puts "# #{$COMPANY.id} has #{$COMPANY.taxes.count} taxes"

puts "Creating some categories"
cat1 = Category.new( {
    :name => "Category 1",
    :tax_id => $COMPANY.taxes.first.id
} )
cat1.set_model_owner
cat1.save

cat2 = Category.new( {
    :name => "Category 2",
    :tax_id => c3.taxes.first.id
} )
cat2.set_model_owner(owner2,c3)
cat2.save

puts "# Company #{$COMPANY.id} has a category '#{$COMPANY.categories.first.name}'"
puts "# Company #{c3.id} has a category '#{c3.categories.first.name}'"
puts "# Creating som Articles"

a1 = Article.new({
    :name => "Test Article",
    :category_id => cat1.id,
    :price => 3.49
})
a1.set_model_owner
if not a1.save then
  puts "a1 failed to save"
end

puts "#{$COMPANY.id} has #{$COMPANY.articles.count} articles"

