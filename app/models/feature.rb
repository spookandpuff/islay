class Feature < ActiveRecord::Base
  belongs_to  :page
  has_one     :primary_asset,   :class_name => 'Asset'
  has_one     :secondary_asset, :class_name => 'Asset'

  validations_from_schema
  track_user_edits

  attr_accessible(
    :primary_asset_id, :secondary_asset_id, :title, :description,
    :styles, :position
  )
end
