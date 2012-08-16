class AssetVersions
  attr_accessor :urls

  def initialize(key, filename, version_names)
    @urls  = version_names.inject({}) do |acc, name|
      acc[name] = AssetStorage.partial_url_for(key, "#{name}_#{filename}")
      acc
    end

    @urls[:original] = AssetStorage.partial_url_for(key, filename)
  end

  def empty?
    !@urls or @urls.empty?
  end

  def url(name, protocol = 'http')
    "#{protocol}://#{@urls[name]}"
  end
end
