class String
  # Creates a hash from a valid double quoted hstore format, 'cause this is
  # the format that postgresql spits out.
  #
  # @return Hash
  #
  # @note Review this when upgrading activerecord-postgres-hstore, since this
  # method is actually a patched version, fixing the issue with adding double
  # quotes.
  def from_hstore
    token_pairs = (scan(hstore_pair)).map { |k,v| [k,v =~ /^NULL$/i ? nil : v] }
    token_pairs = token_pairs.map { |k,v|
      [k,v].map { |t|
        case t
        when nil then t
        when /\A"(.*)"\Z/m then $1.gsub(/\\(.)/, '\1')
        else t.gsub(/\\(.)/, '\1')
        end
      }
    }
    Hash[ token_pairs ]
  end
end

# We're reopening the built-in time class and adding some useful methods. These
# are mainly useful in reporting, but are also useful for querying large 
# collections of records.
#
# They depend on the ActiveSupport Time extensions and thus are not very 
# portable.
class Time
  # Returns the week of the year.
  #
  # @return Integer
  def week
    strftime("%U").to_i # %W for weeks starting monday
  end

  # Creates a new instance of time at the specified month, year and time zone.
  #
  # @param Integer month
  # @param Integer year
  # @param String zone
  # @return Time
  def month_in_zone(month, year, zone)
    zoned = in_time_zone(zone)
    advance(:years => year - zoned.year, :months => month - zoned.month)
  end

  # Creates a new instance of time at the specified week of the year, year and
  # time zone. Care should be taken with this method, since the week of the 
  # year is dependent on the start of the week, which varies across locales.
  #
  # In other words, make sure you're asking for the right week for the zone
  # specified.
  #
  # @param Integer month
  # @param Integer year
  # @param String zone
  # @return Time
  def week_in_zone(week, year, zone)
    zoned = in_time_zone(zone)
    zoned.advance(:years => year - zoned.year, :weeks => week - zoned.week)
  end

  # Creates an instance of time at the specified day of month, month, year and
  # time zone.
  #
  # @param Integer day
  # @param Integer month
  # @param Integer year
  # @param String zone
  # @return Time
  def day_in_zone(day, month, year, zone)
    zoned = in_time_zone(zone)
    advance(:years => year - zoned.year, :months => month - zoned.month, :days => day - zoned.day)
  end
end
