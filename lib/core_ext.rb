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
