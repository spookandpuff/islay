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
  def self.search(term, only = @@queries.keys)
    queries = @@queries.select {|k, v| only.include?(k)}.map {|k, v| v}
    query   = sanitize_sql_array([queries.join(" UNION ALL "), {:term => term.split(' ').join('&')}])

    sql = select('*')
            .from("(#{query}) AS candidates")
            .where('rank > 0')
            .order('rank DESC')
            .limit(25).to_sql

    find_by_sql(sql)
  end
end
