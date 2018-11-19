Time::DATE_FORMATS.merge!(
  :default    => "%d %b %Y %H:%M:%S GMT%z",
  :param      => "%Y-%m-%d-%H-%M",
  :pretty     => lambda { |time| time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase },
  :date_only  => "%d/%m/%Y",
  :month_year => "%B %Y"
)
