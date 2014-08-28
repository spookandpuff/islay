module Islay
  module Engines
    # Shortcuts for requiring/preloading certain classes and then extending 
    # them. For now this only supports extending controllers and helpers.
    module Requiring
      # Extend a controller within a specified scope.
      #
      # @param Symbol scope
      # @param Symbol name
      # @param Proc blk
      # @return nil
      def extend_controller(scope, name, &blk)
        extend_object(scope, "controllers", "#{name}_controller", &blk)
      end

      # Extend a helper within a specified scope.
      #
      # @param Symbol scope
      # @param Symbol name
      # @param Proc blk
      # @return nil
      def extend_helper(scope, name, &blk)
        extend_object(scope, "helpers", "#{name}_helper", &blk)
      end

      private

      # A helper for loading then extending a class within the Engine's app 
      # dir.
      #
      # @param Symbol scope
      # @param Symbol type
      # @param Symbol name
      # @param Proc blk
      # @return nil
      def extend_object(scope, type, name, &blk)
        mod = self.to_s.split(":").first.underscore
        path = [mod, scope, name].join('/')
        require_dependency(root.join('app', type, path).to_s)
        klass = path.classify.constantize
        klass.class_eval(&blk)

        nil
      end
    end
  end
end
