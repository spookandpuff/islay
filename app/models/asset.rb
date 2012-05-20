class Asset < ActiveRecord::Base
  belongs_to :album, :class_name => 'AssetAlbum', :foreign_key => 'asset_group_id', :counter_cache => true

  class_attribute :kind

  mount_uploader :upload, AssetUploader
  mount_uploader :preview, PreviewUploader
  process_in_background :upload, AssetUploader::Worker

  attr_accessible :name, :upload, :upload_cache, :asset_group_id, :status, :error, :retries

  after_initialize  :set_path
  before_save       :set_name, :set_metadata

  track_user_edits

  IMAGE_EXTENSIONS = %w(jpg jpeg png gif).freeze
  DOCUMENT_EXTENSIONS = %w(doc xls pdf zip pages numbers psd indd txt rtf).freeze
  VIDEO_EXTENSIONS = %w(mpg mp4 mov avi).freeze
  AUDIO_EXTENSIONS = %w(mp3 aiff acc flac wav).freeze

  def version_info
    upload.version_info
  end

  def friendly_duration
    "#{(duration / 60).round(2)} minutes" if duration
  end

  def extension
    File.extname(self[:upload]).split('.').last
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

  def set_metadata
    if upload_changed?
      self.original_filename  =  upload.filename
      self.content_type       = MIME::Types.type_for(upload.file.path).first.to_s
      self.filesize           = File.size(upload.file.path)
      self.status             = 'enqueued'
    end
  end

  def set_name
    if name.blank? and upload_changed?
      name = upload.filename.split('.').first.humanize
      count = Asset.count(:conditions => ["name LIKE ? AND type = ?", "#{name}%", type])
      self.name = if count > 0
        "#{name} (#{count + 1})"
      else
        name
      end
    end
  end

  def set_path
    self.path ||= Time.now.strftime("%Y/%m/%d/%H/%M/%S/%L")
  end
end
