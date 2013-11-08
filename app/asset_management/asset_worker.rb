# This is a Girl Friday worker which handles background processing of asset 
# uploads. This covers the initial upload of an asset, deletion, update or 
# just reprocessing. Reprocessing is user-initiated, usually after an error.
class AssetWorker
  # Enqueues a job related to the provided asset. The tasks include importing
  # a new asset, updating, reprocessing or deleting.
  #
  # @param Asset asset
  # @param [:create, :update, :reprocess, :delete] mode
  # @param Hash opts
  # @return nil
  def self.enqueue!(asset, mode, opts = {})
    ASSET_QUEUE << self.new(asset, mode, opts)

    nil
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

  # Performs the enqueued operation. It will conditionally process a new asset,
  # update, reprocess or delete.
  #
  # @return nil
  def perform
    case @mode
    when :create    then perform_create
    when :update    then perform_update
    when :reprocess then perform_reprocess
    when :delete    then perform_deletion
    end

    nil
  end

  private

  def perform_create
    AssetStorage.move!(@opts[:path], @asset.path)
    process_and_upload(@asset.path, @asset.directory)
  end

  def perform_update
    AssetStorage.destroy!(@opts[:previous])
    AssetStorage.move!(@opts[:path], @asset.path)
    process_and_upload(@asset.path, @asset.directory)
  end

  def perform_reprocess
    process_and_upload(@asset.path, @asset.directory)
  end

  # 
  def perform_deletion
    AssetStorage.destroy!(@asset.path)
  end

  # Delete prefix
  # move and rename
  # Overwrite/replace
  # Upload reprocessed files


  # Caches a file stored in the file store in a temp directory, processing it
  # according to the definitions attached to the asset, uploads the files and 
  # cleans up temp files.
  #
  # @param String from
  # @param String to
  # @param [true, false] cleanup
  # @return nil
  def process_and_upload(from, to, cleanup = true)
    tmp_path  = AssetStorage.cache!(from)
    processor = @asset.asset_processor.new(tmp_path)
    data      = processor.extract_metadata!
    paths     = ? processor.processable? ? processor.process! : []

    # Extract/update metadata
    data = processor.extract_metadata!
    @asset.update_attributes(data)

    # Store needs to be dumber. We tell it from, and to
    AssetStorage.store!(paths, to)

    # Remove everything at these paths
    AssetStorage.flush!(tmp_path, *paths) if cleanup

    nil
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
      data      = processor.extract_metadata!

      paths = if processor.processable?
        processor.process!
      else
        []
      end

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
