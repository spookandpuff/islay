Islay::Engine.routes.draw do
  namespace :admin do
    get '/' => 'dashboard#index', :as => 'dashboard'
  end
end
