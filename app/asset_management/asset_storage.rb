# This class is responsible for handling everything related to storing and
# caching assets. It stores assets, caches them locally and removes them from
# the remote store.
class AssetStorage
  # Generates the URL for a
  def self.partial_url_for(dir, key, filename)
    "#{Settings.for(:islay, :assets_bucket)}.s3.amazonaws.com/#{dir}/#{key}/#{filename}"
  end

  # Takes an array of paths and moves them into the store, using the key as a
  # prefix and the basename of each path as the filename.
  #
  # @param String dir
  # @param String key
  # @param Array<String> paths
  #
  # @return Array<String>
  def self.store!(dir, key, paths)
    bucket = get_bucket

    paths.map do |path|
      File.join(dir, key, File.basename(path)).tap do |l|
        body = File.open(path)
        file = bucket.files.create(:key => l, :public => true, :body => body.read)
        body.close
      end
    end
  end

  # Removes all the files at a particular prefix.
  #
  # @param String key
  # @param Array<String> paths
  #
  # @return Array<String>
  def self.destroy!(key, paths)
    bucket = get_bucket

    paths.map do |path|
      File.join(key, File.basename(path)).tap do |l|
        bucket.files.destroy(l)
      end
    end
  end

  # Copies a file from out of the store into a temporary directory.
  #
  # @param String key
  # @param String path
  #
  # @return File
  def self.cache!(key, path)
    if cached?(key)
      File.open(File.join(key, path))
    else
      File.open(File.join(temp_dir_at(key), path), 'wb+') do |f|
        file = get_bucket.files.get(File.join(key, path))
        f.write(file.body)
      end
    end
  end

  # Caches a file into temporary direcory,
  #
  # @param String key
  # @param String filename
  # @param File file
  #
  # @return String
  def self.cache_file!(key, filename, file)
    path = File.join(temp_dir_at(key), filename)
    FileUtils.cp(file.path, path)
    path
  end

  # Checks to see if a file is in the local cache.
  #
  # @param String key
  #
  # @return Boolean
  def self.cached?(key)
    File.exists?(Rails.root + 'tmp' + key)
  end

  # Removes a file from the local cache.
  #
  # @param String key
  def self.flush!(key)
    path = Rails.root + 'tmp' + key
    FileUtils.rm_rf(path) if File.exists?(path)
  end

  private

  def self.temp_dir_at(key)
    path = File.join(Rails.root, 'tmp', key)
    FileUtils.mkdir(path) unless File.exists?(path)
    path
  end

  def self.get_bucket
    Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Settings.for(:islay, :aws_id),
      :aws_secret_access_key    => Settings.for(:islay, :aws_secret)
    }).directories.get(Settings.for(:islay, :assets_bucket))
  end
end
