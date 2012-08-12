class Search < ActiveRecord::Base
  @@queries = []
  def self.columns() @columns ||= []; end

  def self.register(klass, query)
    @@queries << [klass.to_s, klass.table_name.singularize, query]
  end

  def self.search(term)
    query = @@queries.map do |q|
      type, name, fragment = q
      terms = if fragment.to_sql.index('type')
        sanitize_sql_array(["'#{name}' AS helper, ts_rank(terms, to_tsquery(?)) AS rank", term])
      else
        sanitize_sql_array(["'#{type}' AS type, '#{name}' AS helper, ts_rank(terms, to_tsquery(?)) AS rank", term])
      end
      fragment.select(terms).order('rank DESC').limit(20).to_sql
    end.join('\nUNION ALL\n')

    sql = select('*')
            .from("(#{query}) AS candidates")
            .where('rank > 0')
            .order('rank DESC')
            .limit(25).to_sql

    find_by_sql(sql)
  end
end
