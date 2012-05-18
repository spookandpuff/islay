class PreviewUploader < AssetUploader
  include CarrierWave::RMagick

  version :thumb do
    process :resize_to_fill => [200, 180, ::Magick::CenterGravity]
  end

  version :thumb_small do
    process :resize_to_fill => [100, 90, ::Magick::CenterGravity]
  end
end
