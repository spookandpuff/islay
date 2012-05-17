class AssetUploader < CarrierWave::Uploader::Base
  def preview

  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def store_dir
    model.path
  end

  # Intercept carrierwave#cache_versions! so we can process versions later.
  # def cache_versions!(new_file)
  #   super(new_file) if model.enable_processing
  # end

  def process!(new_file=nil)
    super(new_file) if model.status == 'enqueued'
  end

  class ProcessWorker
    def self.queue
       'process_assets'
    end

    def self.enqueue(model)
      Resque.enqueue(self, model.id)
    end

    def self.perform(id)
      if model = Asset.find(id)
        model.update_attribute(:status, 'processing')
        begin
          if model.upload.present?
            model.upload.recreate_versions!
            model.preview = model.upload.preview
            model.preview.recreate_versions!
          end
          model.update_attributes!(
            :status => 'processed',
            :error => nil,
            :retries => 0
          )
        rescue => e
          if model.retries <= 3
            model.retries = model.retries + 1
            self.enqueue(model)
          end
          model.status = 'errored'
          model.error = e.to_s
          model.save!
        end
      end
    end
  end
end
