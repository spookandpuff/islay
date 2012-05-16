Islay::Engine.routes.draw do
  devise_for(
    :users,
    :path         => "admin",
    :path_names   => {:sign_in => 'login', :sign_out => 'logout'},
    :controllers  => { :sessions => "islay/admin/sessions", :passwords => "islay/admin/passwords" }
  )
  get '/' => 'admin/dashboard#index', :as => 'root'

  namespace :admin do
    get '/' => 'dashboard#index', :as => 'dashboard'

    resources :users do
      get :delete, :on => :member
    end
  end
end
