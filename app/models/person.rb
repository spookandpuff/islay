class Person < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable
  validations_from_schema
end
