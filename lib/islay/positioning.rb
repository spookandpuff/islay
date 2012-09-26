class ActiveRecord::Base
  class_attribute :position_scope

  # Turns on the positioning logic for an AR class.
  #
  # @param Symbol scope
  #
  # @return nil
  def self.positioned(scope = nil)
    include Positioning::InstanceMethods
    extend Positioning::ClassMethods

    if scope
      self.position_scope = scope.to_sym
      before_save :reparent_and_position, :if => :"#{scope}_changed?"
    end
  end

  module Positioning
    module ClassMethods
      # Fixes the positions of records in a table. This is a way to fix any
      # positioning that has gone out of skew; it will however destroy any
      # any existing positioning.
      #
      # @return Array<ActiveRecord::Base>
      def fix_positions!
        if self.position_scope
          all.group_by(&self.position_scope).each do |scope, entries|
            entries.each_with_index {|e, i| e.update_attribute(:position, i + 1)}
          end
        else
          all.each_with_index {|e, i| e.update_attribute(:position, i + 1)}
        end
      end
    end

    module InstanceMethods
      # Moves the record one position higher, adjusting the position of it's
      # siblings.
      #
      # @return Boolean
      def move_higher
        move_position(:-, :+)
      end

      # Moves the record one position lower, adjusting the position of it's
      # siblings.
      #
      # @return Boolean
      def move_lower
        move_position(:+, :-)
      end

      private

      # A helper method used to reposition records.
      #
      # @param Symbol op1
      # @param Symbol op2
      #
      # @return Boolean
      def move_position(op1, op2)
        ActiveRecord::Base.transaction do
          new_pos = position.send(op1, 1)

          if position_scope
            self.class.update_all(
              "position = position #{op2} 1",
              ["position = ? AND #{position_scope} = ?", new_pos, send(position_scope)]
            )
          else
            self.class.update_all(
              "position = position #{op2} 1",
              ["position = ?", new_pos]
            )
          end

          update_attribute(:position, new_pos)
        end
      end

      # A before_save hook that re-assigns the position — to the bottom of the
      # list — when the record has been reparented.
      #
      # @return Integer
      def reparent_and_position
        count = if position_scope
          self.class.where("#{position_scope} = ?", send(position_scope)).count
        else
          self.class.count
        end

        self.position = count + 1
      end
    end
  end
end
