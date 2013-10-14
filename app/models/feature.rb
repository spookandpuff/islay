class Feature < ActiveRecord::Base
  belongs_to :page
  belongs_to :primary_asset,   :class_name => 'Asset'
  belongs_to :secondary_asset, :class_name => 'Asset'

  positioned :page_id

  validations_from_schema
  track_user_edits

  attr_accessible(
    :primary_asset_id, :secondary_asset_id, :title, :description,
    :styles, :position, :published, :link_url, :link_title, :page_id
  )
end
