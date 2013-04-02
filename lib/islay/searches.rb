module Islay
  class Searches
    attr_accessor :models, :updates, :assocs

    # Stubs out the contentns of the models, updates and assocs accessors
    #
    # @return Searches
    def initialize
      @models   = Set.new
      @updates  = {}
      @assocs   = Hash.new {|h, k| h[k] = []}
    end

    # Registers a model as being searchable. The block is required, as it it
    # used to generate the search terms and their rankings. See the
    # ./config/initializers/search.rb for an example use.
    #
    # @param Symbol model
    # @param Hash opts
    # @param Proc blk
    #
    # @return nil
    def search(model, opts = {}, &blk)
      @models << model
      @updates[model] = blk

      Search.register(model, opts)

      nil
    end

    # Used to establish dependencies between models. This allows terms to be
    # propogated between associations.
    #
    # @param Symbol model
    # @param Symbol association
    #
    # @return nil
    def depends(model, association)
      @models << model
      @assocs[model] << association
      
      nil
    end
  end
end

