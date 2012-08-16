class AssetWorker
  def self.enqueue!(asset, file_path, store_original = false)
    ASSET_QUEUE << self.new(asset, file_path, store_original)
  end

  def initialize(asset, file_path, store_original = false)
    @asset = asset
    @file_path = file_path
    @store_original = store_original
  end

  # @todo Update record with processing status
  def perform
    @asset.update_attribute(:status, 'processing')

    processor = @asset.asset_processor.new(@file_path)
    paths = processor.process!
    data = processor.extract_metadata!
    paths << @file_path if @store_original
    AssetStorage.store!(@asset.dir, @asset.key, paths)
    AssetStorage.flush!(@asset.key)

    data[:status] = 'processed'
    @asset.update_attributes(data)
  end
end
