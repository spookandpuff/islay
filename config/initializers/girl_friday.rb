ASSET_QUEUE = GirlFriday::WorkQueue.new(:asset_processing) do |worker|
  worker.perform
end
