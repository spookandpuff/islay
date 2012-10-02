class ImageAssetProcessor < AssetProcessor
  def processable?
    true
  end

  def process_version!(path, &blk)
    copy = source.copy
    blk.call(copy)
    copy.write(path)
  end

  def self.preview?
    true
  end

  def preview_path
    @file
  end

  # Returns a hash of meta data extracted from the image e.g. colorspace,
  # dimensions etc.
  #
  # @return Hash
  def extract_metadata!
    super({
      :width      => source.columns,
      :height     => source.rows,
      :colorspace => source.colorspace.to_s.match(/^(.+)Colorspace/)[1]
    })
  end

  private

  def source
    @source ||= Magick::ImageList.new(@file).first
  end
end
