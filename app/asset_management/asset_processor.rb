# Handles all processing tasks. This is an abstract class, which needs to be
# specialised for each type of asset e.g. images, videos…
class AssetProcessor
  class_attribute :versions, :previews
  self.previews = {}

  def self.inherited(klass)
    klass.versions = {}
  end

  def self.config(&blk)
    class_eval(&blk)
  end

  def self.version(name, &blk)
    versions[name] = blk
  end

  def self.version_names
    versions.keys
  end

  def self.preview_names
    previews.keys
  end

  def self.preview(name, &blk)
    previews[name] = blk
  end

  attr_reader :paths

  def initialize(file)
    @file     = file
    @filename = File.basename(file)
    @dir      = File.dirname(file)
    @paths    = []
  end

  # Indicates if we should attempt to process the asset. By default this is
  # false. Where needed, it's implementation should be over-ridden in the
  # sub-classes.
  #
  # @return Boolean
  def processable?
    false
  end

  # Processes the versions and previews for an asset.
  #
  # @return Array<String>
  def process!
    process_previews! if self.class.preview?

    versions.each do |name, blk|
      path = File.join(@dir, "#{name}_#{@filename}")
      process_version!(path, &blk)
      @paths << path
    end

    @paths
  end

  # Processes an individual version, using the provided blog and saving it at
  # the specified path. This should be implemented in each sub-class.
  #
  # @param String path
  # @param Proc blk
  #
  # @return nil
  def process_version!(path, &blk)
    raise NotImplementedError
  end

  # Extracts what metadata it can from an asset and returns it as a hash. The
  # keys in the hash correspond to the attributes in the Asset model.
  #
  # This should be over-ridden in each sub-class.
  #
  # @param Hash data
  #
  # @return Hash
  def extract_metadata!(data = {})
    data.tap do |d|
      file = File.open(@file)
      d[:filesize] = file.size
      file.close

      d[:content_type] = MIME::Types.type_for(@file).first.to_s
    end
  end

  # Indicates if the processor provides an image from which previews can be
  # generated. By default this is false. Subclasses should over-ride this
  # method if they do provide one.
  #
  # @return Boolean
  def self.preview?
    false
  end

  # Provides an image which is used to generate previews. The implementation
  # for this needs to be provided in each sub-class — assuming a preview
  # image can be generated. It is used in conjunction with the #preview?
  # method.
  #
  # @return String path location of the file on disk
  def preview_path
    raise NotImplementedError
  end

  # Generate the previews for the asset.
  #
  # @return Array<String>
  def process_previews!
    source = Magick::ImageList.new(preview_path).first

    previews.each do |name, blk|
      path = File.join(@dir, "#{name}_preview.jpg")

      copy = source.copy
      blk.call(copy)
      copy.write(path)

      @paths << path
    end

    @paths
  end
end

# Declare the built-in preview sizes. These are only used in the admin backend
# so we're unlikely to need to change these per app, although that can be
# done if necessary.
AssetProcessor.config do
  preview(:thumb) do |img|
    img.resize_to_fit!(300, 280)
  end

  preview(:thumb_medium) do |img|
    img.resize_to_fill!(160, 160)
  end

  preview(:thumb_small) do |img|
    img.resize_to_fill!(60, 60)
  end
end
