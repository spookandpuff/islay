class Search < ActiveRecord::Base
  @@queries = []

  def self.register(name, query)
    @@queries << [name, query]
  end

  def self.search(term)
    query = @@queries.map do |q|
      name, fragment = q
      terms = sanitize_sql_array(["'#{name}' AS helper, s_rank(terms, to_tsquery(?)) AS rank", term])
      fragment.select(terms).order('rank DESC').limit(20).to_sql
    end.join('\nUNION ALL\n')

    select('*').from("(#{query})").order('rank DESC').limit(25).to_sql
  end
end
