class Asset < ActiveRecord::Base
  belongs_to :category, :class_name => 'AssetCategory'

  mount_uploader :upload, AssetUploader

  attr_accessible :name, :upload, :upload_cache, :asset_category_id

  after_initialize :set_path

  # Provides access to the user model provided by Devise.
  def current_user
    Thread.current[:current_user]
  end

  # A callback handler which updates the user ID columns before save
  def update_user_ids
    self.creator_id = current_user.id if new_record?
    self.updater_id = current_user.id
  end

  # Installs a before_save hook for updating the user IDs against a record.
  # This requires the creator_id and updater_id columns to be in the table.
  #
  # This method also installs to associations; creator, updater
  def self.track_user
    # before_save :update_user_ids
    # belongs_to :creator, :class_name => 'User'
    # belongs_to :updater, :class_name => 'User'
  end
  # track_users

  def self.derp
    before_save :update_user_ids
    belongs_to :creator, :class_name => 'User'
    belongs_to :updater, :class_name => 'User'
  end

  derp

  IMAGE_EXTENSIONS = %w(jpg jpeg png gif).freeze
  DOCUMENT_EXTENSIONS = %w(doc xls pdf zip pages number psd indd).freeze
  VIDEO_EXTENSIONS = %w(mpg mp4 mov avi).freeze
  AUDIO_EXTENSIONS = %w(mp3 aiff acc flac wav).freeze

  def extension
    File.basename(self[:upload])
  end

  def self.choose_type(ext)
    case ext
    when *IMAGE_EXTENSIONS     then ImageAsset.new
    when *DOCUMENT_EXTENSIONS  then DocumentAsset.new
    when *VIDEO_EXTENSIONS     then VideoAsset.new
    when *AUDIO_EXTENSIONS     then AudioAsset.new
    else self.new
    end
  end

  private

  def set_path
    self.path ||= Time.now.strftime("%Y/%m/%d/%H/%M/%S/%L")
  end
end
