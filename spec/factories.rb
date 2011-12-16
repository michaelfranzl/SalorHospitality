Factory.define :user do |f|
  f.sequence(:login) { |n| "user#{n}" }
  f.password "secret"
  #f.title "Mr. User"
end
