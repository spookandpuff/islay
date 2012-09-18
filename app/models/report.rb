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

  # Generates a query by interpolating the appropriate time predicate functions
  # into the provided string. It then executes the query using #select_all.
  #
  # @param String query
  # @param Hash range
  # @param String col
  # @param String prev_col
  #
  # @return Array<Hash>
  def self.select_all_by_range(query, range, opts)
    col      = opts.delete(:column)
    prev_col = opts.delete(:previous_column)

    prepared = case range[:mode]
    when :month, :none
      if range[:mode] == :none
        now = Time.now
        year = now.year
        month = now.month
      else
        year = range[:year]
        month = range[:month]
      end

      query.gsub(/(:current|:previous)/) do |match|
        case match
        when ':current'   then "within_month(#{year}, #{month}, #{col})"
        when ':previous'  then "within_previous_month(#{year}, #{month}, #{prev_col || col})"
        end
      end
    when :range
      from  = "'#{range[:from]}'"
      to    = "'#{range[:to]}'"

      query.gsub(/(:current|:previous)/) do |match|
        case match
        when ':current'   then "within_dates(#{from}, #{to}, #{col})"
        when ':previous'  then "within_previous_dates(#{from}, #{to}, #{prev_col || col})"
        end
      end
    end

    select_all(prepared, opts)
  end
end
