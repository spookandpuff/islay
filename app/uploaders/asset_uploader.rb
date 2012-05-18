class AssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::DelayStorage

  def preview

  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def store_dir
    model.path
  end

  class Worker < Struct.new(:klass, :id, :column)
    @queue = :process_asset

    def self.perform(*args)
      new(*args).perform
    end

    def perform
      resource = klass.is_a?(String) ? klass.constantize : klass
      record = resource.find(id)

      if record
        # Assign the preview first. This is important for any previews that are
        # generated from the original file without copying it.
        record.preview = record.upload.preview

        # Process the upload
        record.process_upload_upload = true
        record.upload.recreate_versions!

        # Running save here kicks off the preview generation, but since some
        # uploaders may not generate them, we only do this if it's been assigned.
        record.save! if record.preview.present?
      end
    end
  end
end
