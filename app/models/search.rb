class Search < ActiveRecord::Base
  belongs_to :searchable, :polymorphic => true

  @@queries = {}

  def self.columns() @columns ||= []; end
  def readonly?; true; end

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

  # Updates the search terms for the specified model.
  #
  # @params ActiveRecord::Base model
  # @params Symbol name
  #
  # @return Boolean
  def self.update_entry(model, name = nil)
    name ||= model.class.to_s.underscore.to_sym
    blk = Islay::Engine.searches.updates[name]

    if blk
      terms = blk.call(model).reject{|k, v| k.empty?}.map do |term, weight|
        "setweight(to_tsvector('pg_catalog.english', '#{term}'), '#{weight}')"
      end
      update = "UPDATE #{model.class.table_name} SET terms = (#{terms.join(' || ')}) WHERE id = #{model.id}"
      ActiveRecord::Base.connection.execute(update)
    else
      false
    end
  end

  # Bootstraps the registration of classes that are searchable.
  #
  # @return nil
  def self.setup
    Islay::Engine.searches.registrations.each do |r|
      register(*r)
    end

    nil
  end

  private

  # Registers a class as being searchable and generates/caches the required
  # query fragment
  #
  # @param Symbol name
  # @param Hash opts
  #
  # @return String
  def self.register(name, opts = {})
    klass = name.to_s.classify

    projections = ["id, id AS searchable_id"]

    projections << if opts[:name]
      "#{opts[:name]} AS name"
    else
      "name"
    end

    projections << if opts[:inherited]
      "type AS searchable_type"
    else
      "'#{klass}' AS searchable_type"
    end

    projections << "ts_rank(terms, to_tsquery(:term)) AS rank"

    sql = klass.constantize.select(projections.join(', ')).order('rank DESC').limit(20).to_sql

    @@queries[klass] = "(#{sql})"
  end
end

# When this file is lazily required, setup the registration of searchable 
# classes.
Search.setup
