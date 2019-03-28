module ActiveRecord
  module Querying

    # An unfortunate monkey patch for AR 5.2.2.1, which doesn't work with finders defined on abstract classes
    def find_by_sql(sql, binds = [], preparable: nil, &block)
      result_set = connection.select_all(sanitize_sql(sql), "#{name} Load", binds, preparable: preparable)
      column_types = result_set.column_types.dup
      columns_hash.each_key { |k| column_types.delete k }
      message_bus = ActiveSupport::Notifications.instrumenter

      payload = {
        record_count: result_set.length,
        class_name: name
      }

      message_bus.instrument("instantiation.active_record", payload) do
        result_set.map { |record| instantiate(record, column_types, &block) }
      end
    end
  end
end
