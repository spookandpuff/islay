class AssetLogDecorator < LogDecorator
  def url
    h.admin_asset_url(model.id)
  end
end
