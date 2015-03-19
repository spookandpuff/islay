class Person < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable
end
