Rails.application.routes.draw do
  root 'users#index'

  get  'login'       => 'users#login'
  post 'login_try'   => 'users#login_try'

  resources :users, :only => [:edit, :update, :new, :create]

  get  'd/:id'       => 'file_objects#index',     as: :directory
  post 'create'      => 'file_objects#create'
  post 'destroy'     => 'file_objects#destroy'
  post 'cut'         => 'file_objects#cut'
  post 'paste'       => 'file_objects#paste'
  post 'rename'      => 'file_objects#rename'

  get  'f/:id'       => 'file_objects#download',  as: :file
  post 'upload'      => 'file_objects#upload',    as: :upload
end
