User.blueprint do
  name      { Faker::Name.name }
  email     { Faker::Internet.email(object.name) }
  password  { 'name' }
end
