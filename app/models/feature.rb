class Feature < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title]

  belongs_to :page
  belongs_to :primary_asset,   :class_name => 'Asset'
  belongs_to :secondary_asset, :class_name => 'Asset'

  positioned :page_id

  track_user_edits
  validations_from_schema

  # Returns the options required for generating a URL to this model. This is
  # currently used with searches.
  #
  # @return Hash
  def searchable_url_opts
    [page, self]
  end
end
