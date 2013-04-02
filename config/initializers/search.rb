Islay::Engine.searches do |config|
  # @todo Pull tags in against this asset as well.
  config.search(:asset, :inherited => true) do |a|
    {a.name => 'A'}
  end
end

