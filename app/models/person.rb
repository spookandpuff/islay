class Person < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable
  attr_accessible :name, :email, :password
end
