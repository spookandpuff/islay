class ImageAsset < Asset
  self.kind = 'image'

  mount_uploader :upload, ImageUploader

  before_save :set_image_metadata

  private

  def set_image_metadata
    if upload_changed? and upload.present?
      upload.manipulate! do |img|
        self[:width] = img.columns
        self[:height] = img.rows

        match = img.colorspace.to_s.match(/^(RGB|CMYK)\w+/)
        self[:colorspace] = if match
          match[1]
        else
          'RGB'
        end

        img
      end

      self[:orientation] = if self[:width] > self[:height]
        'landscape'
      else
        'portrait'
      end
    end
  end
end
