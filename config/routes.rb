Rails.application.routes.draw do
  root 'root#index'

  get  'login'      => 'users#login'
  post 'login_try'  => 'users#login_try'

  resources :users, :only => [:update, :new, :create]
  get 'users' => 'users#edit',  as: :user_edit

  get  ':id_hash' => 'root#index',  as: :directory

  resources :file_objects, :only => [:create, :update, :new] do
    collection do
      get  ':id_hash'  => 'file_objects#index'
      delete  ':id_hash'  => 'file_objects#destroy'
    end
  end

  get  'p/:id_hash' => 'file_objects#parent_directories_list'
  get  'f/:id_hash' => 'file_objects#file_download'
end
