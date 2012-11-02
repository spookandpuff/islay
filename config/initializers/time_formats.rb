Time::DATE_FORMATS.merge!(
  :default  => "%d %b %Y %H:%M:%S %Z",
  :param    => "%Y-%m-%d-%H-%M",
  :pretty   => lambda { |time| time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase }

)
