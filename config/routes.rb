Islay::Engine.routes.draw do
  # RESQUE
  mount Resque::Server.new, :at => "/resque"

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
    scope :path => 'library' do
      get '/' => 'asset_library#index', :as => 'asset_library'

      # Collections and Albums
      resources(:asset_collections, :controller => 'asset_groups', :path => 'collections', :defaults => {:type => 'collection'}) { get :delete, :on => :member }
      resources(:asset_albums,      :controller => 'asset_groups', :path => 'albums', :defaults => {:type => 'album'}) { get :delete, :on => :member }

      # Assets
      asset_resource = lambda do
        collection do
          get :bulk
          post :bulk, :action => 'bulk_create'
        end

        member do
          get :delete
          put :reprocess
        end
      end

      asset_resources = [:assets, :image_assets, :document_assets, :video_assets, :audio_assets]
      asset_resources.each do |as|
        resources as, :controller => 'assets', :defaults => {:type => as}, &asset_resource
      end
    end
  end

  # Funky shortcuts for adding assets directly to an album
  get 'admin/library/assets/new/for-album/:asset_album_id' => 'admin/assets#new', :as => 'new_admin_asset_asset_album'
end
