class Asset < ActiveRecord::Base
  belongs_to :category, :class_name => 'AssetCategory'

  class_attribute :kind

  mount_uploader :upload, AssetUploader

  attr_accessible :name, :upload, :upload_cache, :asset_category_id

  after_initialize :set_path

  track_user_edits

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
