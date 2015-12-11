FactoryGirl.define do
  factory :season do
    company_id 1
    vendor_id 1
    color "#d6c951"

    trait :spring do
      name "Spring"
      from_date Date.parse('2015-03-21')
      to_date Date.parse('2015-06-19')
    end

    trait :summer do
      name "Summer"
      from_date Date.parse('2014-06-20')
      to_date Date.parse('2014-09-19')
    end

    trait :autumn do
      name "Autumn"
      from_date Date.parse('2014-09-20')
      to_date Date.parse('2014-12-20')
    end

    trait :winter do
      name "Winter"
      from_date Date.parse('2014-12-21')
      to_date Date.parse('2015-03-20')
    end

  end
end
