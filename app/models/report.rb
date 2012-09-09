class Report
  private

  # Returns an array of hashes, each representing a row in the result set.
  #
  # @param String query
  # @param [Array, Hash]
  #
  # @return Array<Hash>
  def self.select_all(query, vals = nil)
    ActiveRecord::Base.connection.select_all(sanitize(query, vals))
  end

  # Returns an array of values; the value being the first column in the select.
  #
  # @param String query
  # @param [Array, Hash]
  #
  # @return Array
  def self.select_values(query, vals = nil)
    ActiveRecord::Base.connection.select_values(sanitize(query, vals))
  end

  # Sanitizes a string, optionally interpolating any values that are passed in.
  #
  # @param String query
  # @param [Hash, Array]
  #
  # @return String
  def self.sanitize(query, vals = nil)
    args = if vals
      [query, vals]
    else
      [query]
    end

    ActiveRecord::Base.send(:sanitize_sql_array, args)
  end
end
