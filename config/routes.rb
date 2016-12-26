Rails.application.routes.draw do
  constraints :protocol => secure_protocol do
    devise_for(
      :users,
      :path         => "admin",
      :path_names   => {:sign_in => 'login', :sign_out => 'logout'},
      :controllers  => { :sessions => "islay/admin/sessions", :passwords => "islay/admin/passwords" }
    )
  end

  islay_admin 'islay' do
    # DASHBOARD & SEARCH
    get '/'         => 'dashboard#index',     :as => 'dashboard'
    get '/add-item' => 'dashboard#add_item',  :as => 'add_item'
    get '/search'   => 'search#index',        :as => 'search'

    # REPORTS
    get 'reports' => 'reports#index', :as => 'reports'

    # USERS
    resources :users do
      get '(/filter-:filter)(/sort-:sort)', :action => :index, :as => 'filter_and_sort', :on => :collection
      get :delete, :on => :member
    end

    # PAGE CONTENT
    resources :pages, :only => %w(index edit update) do
      resources :features, :only => %w(new create edit update)
    end

    # ASSET LIBRARY
    scope :path => 'library' do
      get '/'                     => 'asset_library#index',   :as => 'asset_library'
      get '/browser(/:only).json' => 'asset_library#browser', :as => 'browser'

      resources(:asset_groups, :path => 'collections') do
        get :delete, :on => :member
        resources :asset_bulk_uploads, :path => 'bulk_uploads', :only => %w(new create)
      end

      resources :asset_tags, :path => 'tags', :only => %w(index show)

      # Processing
      resources :asset_processes, :path => 'processing', :controller => 'assets', :only => :index do
        collection do
          get '',                               :action => :processing, :as => 'index'
          get '(/filter-:filter)(/sort-:sort)', :action => :processing, :as => 'filter_and_sort'
          patch '',                             :action => :bulk_reprocess
        end
      end

      # Assets
      asset_resource = lambda do
        collection do
          get '(/filter-:filter)(/sort-:sort)', :action => :index, :as => 'filter_and_sort'
          get :bulk
          post :bulk, :action => 'bulk_create'
        end

        member do
          get :delete
          patch :reprocess
        end
      end

      asset_resources = %w(image document video audio)
      asset_resources.each do |s|
        as = "#{s}_assets".to_sym
        resources as, :path => "assets/#{s.pluralize}", :controller => 'assets', :defaults => {:type => s}, &asset_resource
      end

      resources :assets, :defaults => {:type => :assets}, &asset_resource
    end
  end
end
