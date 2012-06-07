class DocumentAsset < Asset
  self.kind = 'doc-text'
  mount_uploader :upload, DocumentUploader
end
