class UsersController < ApplicationController
  before_action :login_check, only: [:edit, :update, :new, :create]
  before_action :admin_check, only: [:new, :create]

  def index
    if signed_in?
      redirect_to directory_path(1)
    else
      redirect_to login_path
    end
  end

  def login
  end

  def login_try
    user = User.find_by(login_id: params[:login_id].downcase)

    if user && user.authenticate(params[:password])
      #認証されたユーザをログインさせる
      sign_in user

      redirect_to root_path
    else
      #flash.now[:error] = 'Invalid email/password combination'

      render :login
    end
  end

  def edit
    @user = current_user
  end

  def update
    user = current_user
    user.update_attributes(user_params)

    flash[:notice] = '更新した'
    redirect_to edit_user_path
  end

  def new
    @user = User.new
  end

  def create
    User.create(user_params)
    flash[:notice] = 'つくた'
    redirect_to root_path
  end

  private

  def login_check
    redirect_to(login_path) if !signed_in?
  end

  def admin_check
    redirect_to(login_path) if !current_user.admin?
  end

  def user_params
    params.require(:user).permit(:login_id, :password, :password_confirmation)
  end
end
