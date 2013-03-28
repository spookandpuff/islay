module Islay
  module Searchable
    def self.included(klass)
      klass.class_eval do
        after_save :update_terms
        class_attribute :search_term_statement

        include InstanceMethods
        extend ClassMethods
      end

    end

    module InstanceMethods
      def update_terms
        statement = ActiveRecord::Base.send(:sanitize_sql_array, [self.class.search_term_statement, id])
        ActiveRecord::Base.connection.execute(statement)
      end
    end

    module ClassMethods
      def search_terms(opts)
        columns   = opts[:map] || {}
        type      = columns.delete(:type)
        terms     = opts[:against]

        projections = ["id, id AS searchable_id"]

        projections << if columns[:name]
          "#{columns[:name]} AS name"
        else
          "name"
        end

        projections << if type == :inherited
          "type AS searchable_type"
        else
          "'#{self.to_s}' AS searchable_type"
        end

        klass = self.to_s.underscore.to_sym
        Search.register(klass, select(projections.join(', ')))

        update = terms.map do |c, r|
          term = if c == :id
            "#{c}::text"
          else
            c
          end

          "setweight(to_tsvector('pg_catalog.english', #{term}), '#{r}')"
        end

        self.search_term_statement = "UPDATE #{table_name} SET terms = (#{update.join(' || ')}) WHERE id = ?"
      end
    end
  end
end
