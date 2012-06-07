class DocumentAsset < Asset
  self.kind = 'doc-text'
  self.friendly_kind = 'Document'
  mount_uploader :upload, DocumentUploader
end
