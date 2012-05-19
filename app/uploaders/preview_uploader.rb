class PreviewUploader < AssetUploader
  include CarrierWave::RMagick

  version :thumb do
    process :resize_to_fill => [300, 280, ::Magick::CenterGravity]
  end

  version :thumb_medium do
    process :resize_to_fill => [150, 130, ::Magick::CenterGravity]
  end

  version :thumb_small do
    process :resize_to_fill => [70, 55, ::Magick::CenterGravity]
  end
end
