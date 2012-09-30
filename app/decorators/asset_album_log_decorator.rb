class AssetAlbumLogDecorator < LogDecorator
  def url
    h.admin_asset_album_path(model.id)
  end
end
