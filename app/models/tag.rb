# An abstract class intended to be inherited from in order to implment tagging
# for specific models. Consequently, this class should _not_ be used directly.
class Tag < ActiveRecord::Base
  self.abstract_class = true

  # Creates a scope that will find any tags that have been orphaned i.e. don't
  # have any taggings associated with them.
  #
  # @return ActiveRecord::Relation
  def self.orphans
    where(%{
      NOT EXISTS (
        SELECT 1 FROM #{tagging_table}
        WHERE #{self.table_name.singularize}_id = #{self.table_name}.id
      )
    })
  end

  private

  # The name of the table used by the tagging class.
  #
  # @return String
  def self.tagging_table
    reflect_on_association(:taggings).klass.table_name
  end
end
