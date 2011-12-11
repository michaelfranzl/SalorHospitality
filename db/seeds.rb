categories = ['Starters','Main Dish','Desserts','Rose Wine','Red Wine','Digestiv','Alcohol','Coffee','Tea','Tobacco','Beer','Aperitiv','White Wine','Side Dish','Divers']

1.upto(2).each do |i|
  result = Company.create :name => "Company #{ i }"
  puts "Company #{ i } created: #{ result.inspect }"
end
