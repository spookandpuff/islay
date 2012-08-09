class DocumentAsset < Asset
  self.kind = 'document'
  self.friendly_kind = 'Document'
  mount_uploader :upload, DocumentUploader
end
