class AudioAsset < Asset
  self.kind = 'audio'
  mount_uploader :upload, AssetUploader
end
