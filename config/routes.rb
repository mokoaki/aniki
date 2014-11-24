Rails.application.routes.draw do
  root 'file_objects#index'

  post 'parent_directories_list' => 'file_objects#parent_directories_list'
  post 'current_files_list'      => 'file_objects#current_files_list'

  post 'proc' => 'file_objects#proc',  as: :proc
  get  'f/:id_hash'       => 'file_objects#download'

  get  'login'       => 'users#login'
  post 'login_try'   => 'users#login_try'

  resources :users, :only => [:update, :new, :create]
  get 'users' => 'users#edit',  as: :user_edit
end
