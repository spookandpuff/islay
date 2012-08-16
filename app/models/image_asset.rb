class ImageAsset < Asset
  self.kind = 'image'
  self.friendly_kind = 'Image'

  self.asset_processor = ImageAssetProcessor

  def dimensions
    "#{width}x#{height}" if width? and height?
  end
end
