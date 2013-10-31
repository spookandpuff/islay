module Islay
  module Logging
    # This includes the the logging module and also adds in hooks which 
    # automatically generate logs whenever a record is saved.
    #
    # It does some clever diffing of the attributes in order to create a 
    # useful log.
    #
    # This module should be used carefully. It should not be used in cases 
    # where you are manually generating logs at specific points.
    #
    # Logging is turned on by using the ::auto_log method. This will allow you
    # specify when it log should run, and how the log should be generated.
    module ActiveRecord
      # This hook includes the Logging module and also sets up an after save
      # hook on the model.
      #
      # @param ActiveRecord::Base klass
      # @return nil
      def self.included(klass)
        klass.send(:include, ::Islay::Logging)
        klass.send(:extend, ClassMethods)
        klass.send(:include, InstanceMethods)
        klass.class_attribute :auto_log_opts
        klass.auto_log_opts = {}
        klass.after_save :run_enqueued_logs
        nil
      end
 
      module ClassMethods
        private
 
        # This turns on auto logging.
        #
        # @param Hash opts
        # @option opts [true, false] :on_update
        # @option opts [true, false] :on_create
        # @option opts [Symbol, proc] :if
        # @option opts [Symbol, proc] :name
        # @option opts Symbol :key
        # @return nil
        def auto_log(opts = {})
          before_save :cache_changes
          after_create :log_creation unless opts[:on_create] == false
          after_update :log_update unless opts[:on_update] == false
 
          auto_log_opts[:if] = opts[:if] if opts.has_key?(:if)
          auto_log_opts[:name] = opts[:name] if opts.has_key?(:name)
 
          auto_log_opts[:key] = opts[:key] || self.to_s.underscore.to_sym
 
          nil
        end
      end
 
      module InstanceMethods
        private

        # Rather than generating logs immediately, this method enqueues a log
        # to be created after save.
        #
        # Refer to Islay::Logging::log for the exact method signature.
        #
        # @return Array
        def enqueue_log(*args)
          (@enqueue_logs ||= []) << args
        end

        # Generates any logs that have been enqueued.
        #
        # @return nil
        def run_enqueued_logs
          if @enqueue_logs and !@enqueue_logs.empty?
            @enqueue_logs.each {|l| log(*l)}
            @enqueue_logs = nil
          end
          nil
        end
 
        # Side-steps AR's Dirty module's default behaviour; once a record is 
        # saved and record of changes is gone. We hold onto them so we can use
        # them in the after create/save hooks.
        #
        # This shouldn't ever be called directly.
        #
        # @return nil
        def cache_changes
          @cached_changes = changes if changed?
          nil
        end
 
        # Generates a log when a record is created. To customise the name added to 
        # the description refer to the :name option in the ::auto_log method.
        #
        # This shouldn't ever be called directly.
        #
        # @return nil
        def log_creation
          if should_log?
            desc = "#{generate_log_name} created"
            opts = {
              :user   => current_user, 
              :for    => self,
              :action => :create
            }

            log(:user, auto_log_opts[:key], desc, opts)
          end
 
          nil
        end
 
        # Generates a log when a record is updated. To customise the name added to 
        # the description refer to the :name option in the ::auto_log method.
        #
        # This shouldn't ever be called directly.
        #
        # @return nil
        def log_update
          if @cached_changes and should_log?
            attrs = @cached_changes.keys.join(', ').humanize.downcase
            desc = "#{generate_log_name} updated - #{attrs} changed"
            opts = {
              :user   => current_user, 
              :for    => self,
              :action => :update
            }

            log(:user, auto_log_opts[:key], desc, opts)
          end
          nil
        end
 
        # A predicate for checking if a log should be created. It will search 
        # for any predicates defined via the :if option passed to ::auto_log
        # otherwise it defaults to true
        #
        # @return [true, false]
        def should_log?
          case auto_log_opts[:if]
          when Proc then auto_log_opts[:if].call(self)
          when Symbol then send(auto_log_opts[:if])
          when nil then true
          end
        end
 
        # Generates the name/prefix for each log. It will use the method or 
        # Proc defined by the :name option passed to the ::auto_log method. 
        # Otherwise it will humanize the class name.
        #
        # @return String
        def generate_log_name
          case auto_log_opts[:name]
          when Proc then auto_log_opts[:name].call(self)
          when Symbol then send(auto_log_opts[:name])
          when nil then self.class.to_s.humanize
          end
        end
      end
    end
  end
end
