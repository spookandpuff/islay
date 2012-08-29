ASSET_QUEUE = GirlFriday::WorkQueue.new(:asset_processing, :size => 2) do |worker|
  worker.perform
end
