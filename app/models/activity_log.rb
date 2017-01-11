class ActivityLog < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def readonly?; true; end

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
    select('*').from(query).order("created_at DESC").limit(count).all.map {|r| components[r.type][0].new(r)}
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
