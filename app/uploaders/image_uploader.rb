class ImageUploader < AssetUploader
  include CarrierWave::RMagick

  def preview
    File.open(current_path)
  end

  version :admin_thumb do
    process :resize_to_fill => [200, 180, ::Magick::CenterGravity]
  end

  version :admin_thumb_small do
    process :resize_to_fill => [100, 90, ::Magick::CenterGravity]
  end
end
