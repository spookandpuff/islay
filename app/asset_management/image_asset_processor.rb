class ImageAssetProcessor < AssetProcessor
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

  private

  def source
    @source ||= Magick::ImageList.new(@file).first
  end
end

ImageAssetProcessor.config do
  version(:derp) do |img|
    img.resize_to_fit!(50, 50)
  end

  version(:what) do |img|
    img.resize_to_fill!(500, 800)
  end
end
