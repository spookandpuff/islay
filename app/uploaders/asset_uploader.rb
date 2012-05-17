class AssetUploader < CarrierWave::Uploader::Base
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def store_dir
    model.path
  end
end
