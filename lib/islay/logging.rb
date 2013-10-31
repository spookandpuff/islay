require 'islay/logging/active_record'

module Islay
  # A module which adds shortcuts for generating activity logs. It can be 
  # included anywhere; it adds class an instance methods.
  module Logging
    # This tricky handler here just makes sure that the log method is 
    # added as a class method as well.
    #
    # @param Class klass
    # @return nil
    def self.included(klass)
      klass.send(:extend, self)
      nil
    end
 
    # Generates an activity log. For more detailed docs, refer to 
    # ActivityLog::add.
    #
    # @param [:system, :user, :public] source
    # @param Symbol key
    # @param String description
    # @param Hash opts
    # @return ActivityLog
    def log(source, key, description, opts = {})
      ActivityLog.add(source, key, description, opts)
    end
  end
end
