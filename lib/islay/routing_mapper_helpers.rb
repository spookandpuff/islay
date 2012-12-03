class ActionDispatch::Routing::Mapper
  # Checks to see if the app should be using https and returns the correct
  # protocol string. This will ensure that the routes generate the urls
  # with the proper protocol, rather than just falling back to the current
  # request.
  #
  # @return String
  def secure_protocol
    @_protocol ||= Settings.use_https? ? 'https://' : 'http://'
  end

  # Defines a set of routes within the 'Admin' submodule of the specified
  # module — e.g. Islay::Admin — with an extra check for the secure protocol.
  #
  # @param String mod
  # @param [Block, Proc]
  #
  # @return nil
  def islay_admin(mod, &blk)
    scope :module => mod do
      namespace(:admin, {:protocol => secure_protocol}, &blk)
    end
  end

  # Defines a set of routes within the 'Public' submodule of the specified
  # module — e.g. Islay::Public
  #
  # @param String mod
  # @param [Block, Proc]
  #
  # @return nil
  def islay_public(mod, &blk)
    scope :module => mod do
      namespace(:public, {:path => ''}, &blk)
    end
  end

  # Defines a set of routes within the 'Public' submodule of the specified
  # module — e.g. Islay::Public — with an extra check for the secure protocol.
  #
  # @param String mod
  # @param [Block, Proc]
  #
  # @return nil
  def islay_secure_public(mod, &blk)
    scope :module => mod do
      namespace(:public, {:path => '', :protocol => secure_protocol}, &blk)
    end
  end
end

