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
        record.process_upload_upload = true
        record.upload.recreate_versions!

        record.preview = record.upload.preview
        record.save! if record.preview.present?
      end
    end
  end
end
