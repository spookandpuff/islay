module Islay
  # This class is intended as a method of encapsulating large SQL queries used
  # by models. Rather than cluttering up your model with constants of frozen
  # SQL queries, you can create a subclass of Query and define these queries
  # as methods on the class.
  #
  # This means your models end up showing _intent_ not the guts, the queries are
  # kept it one place — and not interleaved with other logic — and you get
  # sanitisation for free.
  #
  # The main caveat with this approach is that you have to write an entire SQL
  # query, not a fragment. This hasn't turned out to be a problem in general,
  # since we generally write explicit selects etc. Writing the rest of the
  # query turns out to be not much of a burden.
  class Query
    class_attribute :queries
    class_attribute :model
    self.queries = {}

    private

    # Defines a query class method. It will have the specified name and use a
    # sanitised version of the query string it is passed.
    #
    # The resulting method optionally accepts a hash or array; the values will
    # be interpolated into the query using #sanitize_sql_array
    def self.query(name, query)
      self.queries[name] = query
      query.freeze
      class_eval %{
        def self.#{name}(args = [])
          self.model.find_by_sql(sanitize(self.queries[:#{name}], args))
        end
      }
    end

    # Just a convenience shortcut for sanitizing query inputs.
    def self.sanitize(query, args)
      ActiveRecord::Base.send(:sanitize_sql_array, [query, args])
    end
  end
end
