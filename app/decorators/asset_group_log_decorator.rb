class AssetGroupLogDecorator < LogDecorator
  def url
    h.admin_asset_group_path(model.id)
  end
end
