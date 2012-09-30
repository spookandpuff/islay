class AssetCollectionLogDecorator < LogDecorator
  def url
    h.admin_asset_collection_path(model.id)
  end
end
