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

    COLUMNS = [:id, :name, :type].freeze

    module ClassMethods
      def search_terms(opts)
        columns = opts[:return] || {}
        terms = opts[:against]

        projections = COLUMNS.map do |col|
          "#{columns[col] || col} AS #{col}"
        end

        projections << unless columns.has_key?(:type)
          "'#{self.to_s}' AS type"
        end

        projections << "'#{table_name.singularize}' AS path"

        Search.register(select(projections.join(', ')))

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
