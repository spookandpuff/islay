module Islay
  module Taggable
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        extend ClassMethods

        after_save :rebuild_taggings
        validates :tag_summary, :presence => true
        attr_accessible :tag_summary
      end
    end

    module InstanceMethods
      # Returns a comma separated list of tag names applied to this record.
      #
      # If an attribute tag_summary is defined it will use that, otherwise it
      # will generate a summary by traversing the associated tags.
      #
      # @return String
      def tag_summary
        @tag_summary ||= (self[:tag_summary] || tags.map(&:name).join(', '))
      end

      # A writer which sets the @tag_summary ivar.
      #
      # @param String tags
      #
      # @return String
      def tag_summary=(tags)
        @tags_updated = true
        @tag_summary = tags
      end

      private

      # Updates the tags associated with a record, removing taggings or creating
      # new ones where necessary. Additionally, it will remove any orphaned tags.
      def rebuild_taggings
        if @tags_updated
          tag_class = self.class.tag_class
          input     = @tag_summary.split(',').map(&:strip).reject(&:blank?)
          existing  = tags.all.map(&:name)
          deleted   = existing - input
          added     = input - existing

          # Remove taggings and check for orphaned tags
          unless deleted.empty?
            delete_query = ["EXISTS (SELECT 1 FROM #{tag_class.table_name} WHERE name IN (?))", deleted]
            taggings.where(delete_query).delete_all
          end

          # Create new taggings and tags (if nescessary)
          unless added.empty?
            added.each do |name|
              tag = tag_class.find_or_create_by_name(name)
              taggings.create(:tag => tag)
            end
          end

          # Delete orphaned tags
          self.class.tag_class.orphans.delete_all
        end
      end # def rebuild_taggins
    end # InstanceMethods

    module ClassMethods
      # Reflects on the tags association and returns the class it uses.
      #
      # @return Tag
      def tag_class
        reflect_on_association(:tags).klass
      end
    end
  end
end
