class AssetWorker
  def self.enqueue!(asset, mode, opts = {})
    ASSET_QUEUE << self.new(asset, mode, opts)
  end

  # Stores the options to be used later when perform is run.
  #
  # @param Asset asset
  # @param Symbol mode
  # @param Hash opts
  def initialize(asset, mode, opts = {})
    @asset = asset
    @mode = mode
    @opts = opts
  end

  def perform
    begin
      @asset.update_attribute(:status, 'processing')

      # If we're reprocessing, grab the original
      original_path = if @mode == :reprocess
        AssetStorage.cache!(@asset.dir, @asset.key, @asset.filename)
      else
        @opts[:file_path]
      end

      processor = @asset.asset_processor.new(original_path)
      paths     = processor.process!
      data      = processor.extract_metadata!

      # If this is an update, we need to upload the original file as well.
      if @mode == :new or @mode == :update
        paths << original_path
      end

      if @mode == :update
        existing = @opts[:existing]
        AssetStorage.destroy!(existing[:dir], existing[:key], existing[:filenames])
      end

      AssetStorage.store!(@asset.dir, @asset.key, paths)
      AssetStorage.flush!(@asset.key)

      data[:status] = 'processed'
      data[:error] = nil
      @asset.update_attributes(data)
    rescue => e
      @asset.update_attributes(:status => 'errored', :error => e.to_s)
    end
  end
end
