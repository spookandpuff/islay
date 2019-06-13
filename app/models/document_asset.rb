class DocumentAsset < Asset
  self.kind = 'document'
  self.friendly_kind = 'Document'
  self.asset_processor = DocumentAssetProcessor

  def url
    versions.url :original, 'https://'
  end
end
