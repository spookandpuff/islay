require 'schema_monkey'

module SchemaValidationExtension
  module ActiveRecord
    module Base
      module ClassMethods
        def schema_validations(opts = {})

          @config_except ||= []
          @config_only ||= []

          @config_except += [opts[:except]].flatten
          opts[:except] = @config_except

          @config_only += [opts[:only]].flatten
          opts[:only] = @config_only

          super(opts)
        end

      end #ClassMethods
    end #Base
  end #ActiveRecord
end #SchemaValidationExtension

SchemaMonkey.register SchemaValidationExtension