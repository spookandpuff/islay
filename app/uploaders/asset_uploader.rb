class AssetUploader < CarrierWave::Uploader::Base
  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def store_dir
    model.path
  end

  ILLEGALC = /[^\w `#`~!@''\$%&\(\)_\-\+=\[\]\{\};,\.]/.freeze

  def filename
    model[:upload] ||= begin
      if original_filename.present?
        original_filename.gsub(ILLEGALC, '_').downcase
      end
    end
  end
end
