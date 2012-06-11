CARRIERWAVE_QUEUE = GirlFriday::WorkQueue.new(:carrierwave) do |msg|
  worker = msg[:worker]
  worker.perform
end
