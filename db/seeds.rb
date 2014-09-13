# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Let's create some users

10.times do |i|
  User.create name: "user#{i}", email: "email#{i}@gmail.com", password: "password"
  Player.create user_id: i
end
