class Asset < ActiveRecord::Base
  include Islay::Taggable
  include Islay::Searchable

  IMAGE_EXTENSIONS = %w(jpg jpeg png gif).freeze
  DOCUMENT_EXTENSIONS = %w(doc xls pdf zip pages numbers psd indd txt rtf).freeze
  VIDEO_EXTENSIONS = %w(mpg mp4 mov avi).freeze
  AUDIO_EXTENSIONS = %w(mp3 aiff acc flac wav).freeze

  search_terms :map => {:type => :inherited}, :against => {:name => 'A'}

  belongs_to  :album,     :class_name => 'AssetAlbum', :foreign_key => 'asset_group_id', :counter_cache => true
  has_many    :taggings,  :class_name => 'AssetTagging'
  has_many    :tags,      :through => :taggings, :order => 'name'

  class_attribute :kind, :friendly_kind, :asset_processor
  attr_accessible :name, :file, :asset_group_id, :status, :error, :retries, :album

  before_save   :set_name
  after_commit  :enqueue_file_processing

  track_user_edits

  # Used mainly for generating JSON. This method collects all the assets, but
  # with just some extra info injected e.g. is this asset one of the latest?
  #
  # @return ActiveRecord::Relation
  def self.summaries
    select(%{
      id, asset_group_id, name, preview, path, type,
      CASE
        WHEN id IN (SELECT id FROM assets ORDER BY updated_at DESC LIMIT 10) THEN true
        ELSE false
      END AS latest
    }).order('name ASC')
  end

  # Chooses the appropriate asset type based on the extension.
  #
  # @return Asset
  def self.choose_type(ext)
    case ext
    when *IMAGE_EXTENSIONS     then ImageAsset.new
    when *DOCUMENT_EXTENSIONS  then DocumentAsset.new
    when *VIDEO_EXTENSIONS     then VideoAsset.new
    when *AUDIO_EXTENSIONS     then AudioAsset.new
    else self.new
    end
  end

  def friendly_duration
    "#{(duration / 60).round(2)} minutes" if duration
  end

  # Indicates if the asset has any previews. For some assets, we can't provide
  # preview images.
  #
  # @return Boolean
  def preview?
    asset_processor.preview?
  end

  # Indicates if the asset has been processed and therefore has it's previews —
  # potentially — and versions available.
  #
  # @return Boolean
  def processed?
    status == 'processed'
  end

  # Just a simple accessor for exposing an uploaded file before it is processed.
  #
  # @return [File, nil]
  def file
    @file
  end

  # Assigns a file to the asset. This method will generate a sanitized filename
  # store the original filename and create a key by SHA hashing the filename
  # with the time.
  #
  # @param File file
  #
  # @return File
  #
  # @todo Fix the filename sanitization
  def file=(file)
    self[:original_filename] = file.original_filename
    self[:filename] = self[:original_filename].gsub(' ', '-')
    self[:key] = Digest::SHA1.hexdigest(self[:original_filename] + Time.now.to_s)

    @file = file
  end

  # @todo need to check if this is updating an existing file.
  def enqueue_file_processing
    if @file
      path = AssetStorage.cache_file!(key, filename, file)
      AssetWorker.enqueue!(self, path, true)
    end
  end

  # Creates an instance of the AssetVersions class, which generates and provides
  # the URLs for the different versions of an asset.
  #
  # @return AssetVersions
  def versions
    @versions ||= AssetVersions.new(key, filename, asset_processor.version_names)
  end

  # Creates an instance of the AssetVersions class, which generates and provides
  # the URLs for the different versions of an asset, in this case the previews.
  #
  # @return AssetVersions
  def previews
    @previews ||= AssetVersions.new(key, 'preview.jpg', asset_processor.preview_names)
  end

  def set_name
    if name.blank? and filename_changed?
      self.name = filename.split('.').first
    end
  end
end
