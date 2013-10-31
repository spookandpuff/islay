class Feature < ActiveRecord::Base
  include Islay::Logging::ActiveRecord
  auto_log :name => :name

  include PgSearch
  multisearchable :against => [:title]

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

  # Returns the options required for generating a URL to this model. This is
  # currently used with searches.
  #
  # @return Hash
  def searchable_url_opts
    [page, self]
  end
end
