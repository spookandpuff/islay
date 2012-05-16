class Asset < ActiveRecord::Base
  belongs_to :category, :class_name => 'AssetCategory'

  track_users
end
