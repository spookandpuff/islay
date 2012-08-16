class DocumentAsset < Asset
  self.kind = 'document'
  self.friendly_kind = 'Document'
  self.asset_processor = DocumentAssetProcessor
end
