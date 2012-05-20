class AssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::DelayStorage

  class_attribute :version_info_cache
  self.version_info_cache = {}

  def version_info(name = nil)
    version_info_cache ||= versions.inject({}) do |h, v|
      name, uploader = v

      size, format = case uploader
      when ImageUploader
        width, height, ext = nil

        uploader.processors.each do |processor|
          case processor[0]
          when :resize_to_fill, :crop
            width, height = processor[1]
          when :convert
            ext = processor[1].first
          end
        end

        ["#{width}x#{height}", ext || model.extension]
      when VideoUploader
        opts = uploader.processors.first[1].first
        [opts[:resolution] || model.resolution, model.extension]
      when DocumentUploader

      when AudioUploader

      end

      h[name] = {
        :name => name.to_s.humanize,
        :size => size,
        :format => format.upcase,
        :url => uploader.url
      }

      h
    end

    name ? version_info_cache : version_info_cache[name]
  end

  def version_opts(version)
    uploader = versions[version]

    version_opt_cache[version] ||= begin
      opts = {}

      uploader.processors.each do |processor|
        case processor[0]
        when :resize_to_fill, :crop
          opts[:width], opts[:height] = processor[1]
        end
      end

      opts
    end
  end

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
        begin
          # Assign the preview first. This is important for any previews that are
          # generated from the original file without copying it.
          record.preview = record.upload.preview

          # Process the upload
          record.process_upload_upload = true
          record.upload.recreate_versions!

          # Running save here kicks off the preview generation, but since some
          # uploaders may not generate them, we only do this if it's been assigned.
          record.save! if record.preview.present?

          record.update_attributes!(
            :status => 'processed',
            :error => nil
          )
        rescue => e
          record.update_attributes!(
            :status => 'errored',
            :error => e.to_s
          )
        end
      end
    end
  end
end
