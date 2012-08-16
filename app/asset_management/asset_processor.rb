# Handles all processing tasks. This is an abstract class, which needs to be
# specialised for each type of asset e.g. images, videos…
class AssetProcessor
  class_attribute :versions, :previews
  self.versions = {}
  self.previews = {}

  def self.config(&blk)
    class_eval(&blk)
  end

  def self.version(name, &blk)
    versions[name] = blk
  end

  def self.version_names
    versions.keys
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

  # Indicates if the processor provides an image from which previews can be
  # generated. By default this is false. Subclasses should over-ride this
  # method if they do provide one.
  #
  # @return Boolean
  def preview?
    false
  end

  # @todo Add preview processing.
  def process!
    s = source(@file)

    versions.each do |name, blk|
      path = File.join(@dir, "#{name}_#{@filename}")
      process_version!(s, path, &blk)
      @paths << path
    end

    @paths
  end

  def source(file)
    raise NotImplementedError
  end

  def process_version!(source, path, &blk)
    raise NotImplementedError
  end

  # Provides an image which is used to generate previews. The implementation
  # for this needs to be provided in each sub-class — assuming a preview
  # image can be generated. It is used in conjunction with the #preview?
  # method.
  #
  # @return String path location of the file on disk
  def preview_image
    raise NotImplementedError
  end

  def process_previews!(path)
    source = Magick::ImageList.new(@file).first
    # Iterate over the preview versions
  end
end

# Declare the built-in preview sizes. These are only used in the admin backend
# so we're unlikely to need to change these per app, although that can be
# done if necessary.
AssetProcessor.config do
  preview(:thumb) do |img|
    img.resize_to_fill!(300, 280, ::Magick::CenterGravity)
  end

  preview(:thumb_medium) do |img|
    img.resize_to_fill!(150, 130, ::Magick::CenterGravity)
  end

  preview(:thumb_small) do |img|
    img.resize_to_fill!(70, 55, ::Magick::CenterGravity)
  end
end
