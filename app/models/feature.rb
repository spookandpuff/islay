class Feature < ActiveRecord::Base
  belongs_to  :page
  has_one     :asset

  validations_from_schema
  track_user_edits

  attr_accessible :asset_id, :title, :description, :styles, :position
end
