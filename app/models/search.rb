class Search < ActiveRecord::Base
  belongs_to :searchable, :polymorphic => true

  @@queries = {}

  def self.columns() @columns ||= []; end
  def readonly?; true; end

  # Registers a query fragment against the name of a searchable class.
  #
  # @param Symbol klass
  # @param String query
  #
  # @param String
  def self.register(klass, query)
    sql = query
            .select("ts_rank(terms, to_tsquery(:term)) AS rank")
            .order('rank DESC')
            .limit(20).to_sql

    @@queries[klass] = "(#{sql})"
  end
  
  # Searches through the ActiveRecord subclasses that have been registered as 
  # searchable, using the queries provided for each.
  #
  # @param String term
  # @param Array only
  #
  # @return Array<Search>
  def self.search(term, only = nil)
    only    ||= @@queries.keys
    queries = @@queries.select {|k, v| only.include?(k)}.values
    query   = sanitize_sql_array([queries.join(" UNION ALL "), {:term => term.split(' ').join('&')}])

    sql = select('*')
            .from("(#{query}) AS candidates")
            .where('rank > 0')
            .order('rank DESC')
            .limit(25).to_sql

    find_by_sql(sql)
  end

  # If we're in dev mode, wrap the search method so we can greedily load the
  # models, thus allowing us to test the bloody thing.
  if Rails.env.development?
    define_singleton_method(:wrapped_search, method(:search))

    def self.search(term, only = nil)
      Rails.application.eager_load!
      Rails::Engine.subclasses.each(&:eager_load!)
      wrapped_search(term, only)
    end
  end
end
