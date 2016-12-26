# A concern that allows models with a "path" attribute of PostgreSQL's LTREE
# type to be arranged into a hierarchy.
module HierarchyConcern
  extend ActiveSupport::Concern

  # Returns the immediate decendents of the record.
  #
  # @return ActiveRecord::Relation
  def children
    self.class.where("path ~ ?", child_path)
  end

  # Returns all the decendents of a record, not just it's immediate children.
  #
  # @return ActiveRecord::Relation
  def decendents
    self.class.where("path ~ ?", "#{child_path}.*")
  end

  # Returns the ancestors to this record.
  #
  # @return ActiveRecord::Relation
  def ancestors
    if path.present?
      self.class.where("id IN (?)", indexed_path.first)
    else
      self.class.none
    end
  end

  # Returns the parent record - if any.
  #
  # @return [ActiveRecord::Base, nil]
  def parent
    self.class.find(indexed_path.last) if path.present?
  end

  # A setter for the parent. This actually just updates the path on the record.
  #
  # @param ActiveRecord::Base parent
  # @return ActiveRecord::Base
  def parent=(parent)
    if parent.present?
      raise ArgumentError, "Parent cannot be a new record" if parent.new_record?
      self.path = parent.child_path
    else
      self.path = nil
    end
    parent
  end

  # The path to a record's children.
  #
  # @return String
  def child_path
    path.present? ? "#{path}.#{id}" : id.to_s
  end

  # Turns the path into an array.
  #
  # @return Array<Integer>
  def indexed_path
    path.present? ? path.split('.').map(&:to_i) : []
  end

  module ClassMethods
    # Returns all the records that are at the top i.e. have no parent.
    #
    # @return ActiveRecord::Relation
    def top_level
      where("path IS NULL")
    end
  end
end
