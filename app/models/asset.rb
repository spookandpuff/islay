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

  attr_accessible(
    :name, :file, :asset_group_id, :status, :error, :retries, :album, :width,
    :height, :colorspace, :filesize, :content_type
  )

  before_save   :set_name
  after_commit  :enqueue_file_processing
  after_destroy :destroy_file

  track_user_edits

  # Used mainly for generating JSON. This method collects all the assets, but
  # with just some extra info injected e.g. is this asset one of the latest?
  #
  # @return ActiveRecord::Relation
  def self.summaries
    select(%{
      id, asset_group_id, name, key, filename, type, dir,
      CASE
        WHEN id IN (SELECT id FROM assets ORDER BY updated_at DESC LIMIT 10) THEN true
        ELSE false
      END AS latest
    }).order('name ASC')
  end

  # Creates a scope, which filters the records by the specified status.
  #
  # @param String filter
  #
  # @return ActiveRecord::Relation
  def self.filtered(filter)
    filter ? where(:status => filter) : scoped
  end

  # Creates a scope, which sorts the records by the specified field.
  #
  # @param String sort
  #
  # @return ActiveRecord::Relation
  def self.sorted(sort)
    sort ? order(sort) : order('updated_at DESC')
  end

  # Chooses the appropriate asset type based on the extension.
  #
  # @return Asset
  def self.choose_type(ext)
    case ext.downcase
    when *IMAGE_EXTENSIONS     then ImageAsset.new
    when *DOCUMENT_EXTENSIONS  then DocumentAsset.new
    when *VIDEO_EXTENSIONS     then VideoAsset.new
    when *AUDIO_EXTENSIONS     then AudioAsset.new
    else DocumentAsset.new
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

  # A regex of illegal characters that will be removed from the uploaded file
  # in order to create a URL friendly name.
  ILLEGAL_CHARS = /[^\w `#`~!@''\$%&\(\)_\-\+=\[\]\{\};,\.]/.freeze

  # Assigns a file to the asset. This method will generate a sanitized filename
  # store the original filename and create a key by SHA hashing the filename
  # with the time.
  #
  # @param File file
  #
  # @return File
  def file=(file)
    # If we're updating this file, cache the older details so we can use them
    # after a commit
    unless new_record?
      @existing = {:dir => dir, :key => key, :filenames => filenames}
    end

    self[:original_filename] = file.original_filename
    self[:filename] = self[:original_filename].gsub(ILLEGAL_CHARS, '-').downcase
    self[:dir] = dir = Time.now.strftime('%Y%m')
    self[:key] = Digest::SHA1.hexdigest(self[:original_filename] + Time.now.to_s)

    @file = file
  end

  def reprocess!
    AssetWorker.enqueue!(self, :reprocess)
  end

  # @todo need to check if this is updating an existing file.
  def enqueue_file_processing
    if @file
      path = AssetStorage.cache_file!(key, filename, file)

      if @existing
        AssetWorker.enqueue!(self, :update, :file_path => path, :existing => @existing)
      else
        AssetWorker.enqueue!(self, :new, :file_path => path)
      end

      # Remove the file, otherwise you end up in an endless loop of re-queuing
      # everytime this instance of the asset is updated.
      @file = nil
    end
  end

  def filenames
    version_names = asset_processor.version_names.map {|v| "#{v}_#{filename}"}
    preview_names = asset_processor.preview_names.map {|v| "#{v}_preview.jpg"}
    version_names + preview_names + [filename]
  end

  def destroy_file
    AssetStorage.destroy!(dir, key, filenames)
  end

  # Creates an instance of the AssetVersions class, which generates and provides
  # the URLs for the different versions of an asset.
  #
  # @return AssetVersions
  def versions
    @versions ||= AssetVersions.new(dir, key, filename, asset_processor.version_names)
  end

  # Creates an instance of the AssetVersions class, which generates and provides
  # the URLs for the different versions of an asset, in this case the previews.
  #
  # @return AssetVersions
  def previews
    @previews ||= AssetVersions.new(dir, key, 'preview.jpg', asset_processor.preview_names)
  end

  def set_name
    if name.blank? and filename_changed?
      self.name = original_filename.split('.').first
    end
  end
end
