class DocumentAsset < Asset
  self.kind = 'document'
  mount_uploader :upload, DocumentUploader
end
