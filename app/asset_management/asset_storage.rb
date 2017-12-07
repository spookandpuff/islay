# This class is responsible for handling everything related to storing and
# caching assets. It stores assets, caches them locally and removes them from
# the remote store.
class AssetStorage
  # Generates the URL for a
  def self.partial_url_for(dir, key, filename)
    "#{Settings.for(:islay, :library_host)}/#{dir}/#{key}/#{filename}"
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
  # @param String dir
  # @param String key
  # @param Array<String> paths
  #
  # @return Array<String>
  def self.destroy!(dir, key, paths)
    bucket = get_bucket

    paths.map do |path|
      File.join(dir, key, File.basename(path)).tap do |l|
        bucket.files.destroy(l)
      end
    end
  end

  # Copies a file from out of the store into a temporary directory.
  #
  # @param String dir
  # @param String key
  # @param String path
  #
  # @return String
  def self.cache!(dir, key, path)
    full_path = File.join(temp_dir_at(key), path)

    File.open(full_path, 'wb+') do |f|
      file = get_bucket.files.get(File.join(dir, key, path))
      f.write(file.body)
    end

    full_path
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
    puts "------------------------"
    puts "Caching file at key: #{key}"
    puts "-----"
    puts "filename: #{filename}"
    puts "file: #{file}"
    puts "path: #{path}"
    puts "------------------------"

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
