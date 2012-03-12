FactoryGirl.define do

  factory :item do
    inventory_code { "#{Faker::Lorem.words(3).join.slice(0,3)}#{rand(9999)+1000}" }
    serial_number { "#{Faker::Lorem.words(3).join.slice(0,3)}-#{rand(9999)+1000}#{Faker::Lorem.words(3).join.slice(0,2)}#{rand(9999)+1000}" }
    model { Factory :model }
    location { Factory :location }
    supplier { Factory :supplier }
    owner { Factory :inventory_pool }
    inventory_pool { owner }
    invoice_date { Time.local(  (Time.now.year - rand(5) - 1) , (rand(12) + 1), (rand(31)+1) ).to_date }
    price { rand(1500).round(2) }
    is_broken 0
    is_incomplete 0
    is_borrowable 1
    is_inventory_relevant 1
  end

end