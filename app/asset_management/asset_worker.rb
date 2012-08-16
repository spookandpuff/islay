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
    paths = @asset.asset_processor.new(@file_path).process!
    paths << @file_path if @store_original
    AssetStorage.store!(@asset.key, paths)
    AssetStorage.flush!(@asset.key)
  end
end
