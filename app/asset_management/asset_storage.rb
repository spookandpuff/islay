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


  # Generates a URL, policy and signature suitable for uploading a file directly 
  # to s3. The results are to be embedded in the form that points to S3.
  #
  # Be sure to make sure the corresponding policy is set on the target bucket.
  #
  # @param String return_url
  # @return Hash
  def self.s3_policy_and_signature(return_url)
    opts = {
      "expiration" => -2.hours.ago.xmlschema,
      "conditions" => [
        {"bucket" => Settings.for(:islay, :assets_bucket)},
        ["starts-with", "$key", "uploads"],
        {"acl" => "private"},
        {"success_action_status" => "200"},
        {"success_action_redirect" => url}
      ]
    }
    policy = Base64.encode64(opts.to_json).gsub(/\n/, '')
    digest = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), config[:secret], policy)
    signature = Base64.encode64(digest).gsub(/\n/, '')

    {
      :policy     => policy,
      :signature  => signature,
      :url        => "https://#{Settings.for(:islay, :assets_bucket)}.s3.amazonaws.com"
    }
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
