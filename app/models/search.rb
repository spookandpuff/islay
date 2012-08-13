class Search < ActiveRecord::Base
  belongs_to :searchable, :polymorphic => true

  @@queries = []

  def self.columns() @columns ||= []; end
  def readonly?; true; end

  def self.register(query)
    @@queries << query
                  .select("ts_rank(terms, to_tsquery(:term)) AS rank")
                  .order('rank DESC')
                  .limit(20).to_sql
  end

  def self.search(term)
    query = sanitize_sql_array([@@queries.join('\nUNION ALL\n'), {:term => term.split(' ').join('&')}])

    sql = select('*')
            .from("(#{query}) AS candidates")
            .where('rank > 0')
            .order('rank DESC')
            .limit(25).to_sql

    find_by_sql(sql)
  end
end
