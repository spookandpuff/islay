class ActivityLog < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def readonly?; true; end

  self.abstract_class = true

  def self.attribute_names
    @attribute_names ||= attribute_types.keys
  end

  def self.load_schema!
    @columns_hash ||= Hash.new

    # From active_record/attributes.rb
    attributes_to_define_after_schema_loads.each do |name, (type, options)|
      if type.is_a?(Symbol)
        type = ActiveRecord::Type.lookup(type, **options.except(:default))
      end

      define_attribute(name, type, **options.slice(:default))

      # Improve Model#inspect output
      @columns_hash[name.to_s] = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, options[:default])
    end

    # Apply serialize decorators
    attribute_types.each do |name, type|
      decorated_type = attribute_type_decorations.apply(name, type)
      define_attribute(name, decorated_type)
    end
  end

  def persisted?
    false
  end

  class_attribute :components
  self.components = {}

  # Register a named decorator and query to be used when constructing and
  # displaying the log results.
  #
  # @param Symbol name
  # @param Draper::Base decorator
  # @param String query
  #
  # @return Array<Draper::Base, String>
  def self.register(name, decorator, query)
    self.components[name.to_s] = [decorator, query]
  end

  # A finder method which returns the n latest logs.
  #
  # @return Array<Draper::Base>
  def self.recent(count = 25)
    select('*').from(query).order("created_at DESC").limit(count).to_a.map {|r| components[r.type][0].new(r)}
  end

  private

  # A helper method for generating the source of our logs by unioning a
  # collection of select statements.
  #
  # @return String
  def self.query
    "(#{components.map {|n, c| "(#{c[1]})"}.join(" UNION ALL ")}) AS results"
  end
end
