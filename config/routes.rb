Islay::Engine.routes.draw do
  # USER AUTHENTICATION
  devise_for(
    :users,
    :path         => "admin",
    :path_names   => {:sign_in => 'login', :sign_out => 'logout'},
    :controllers  => { :sessions => "islay/admin/sessions", :passwords => "islay/admin/passwords" }
  )

  namespace :admin do
    # DASHBOARD
    get '/' => 'dashboard#index', :as => 'dashboard'

    # USERS
    resources :users do
      get :delete, :on => :member
    end

    # ASSET LIBRARY
    get   'library' => 'asset_categories#index', :as => 'asset_categories'
    post  'library' => 'asset_categories#create'
    resources :asset_categories, :path => 'library/categories' do
      get :delete, :on => :member
    end

    resources :assets, :image_assets, :document_assets, :video_assets, :audio_assets, :controller => 'assets', :path => 'library/assets' do
      get :delete, :on => :member
    end
  end
end
