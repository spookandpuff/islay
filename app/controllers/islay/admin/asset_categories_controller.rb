module Islay
  module Admin
    class AssetCategoriesController < ApplicationController
      resourceful :asset_category
      header 'Asset Library'
    end
  end
end
