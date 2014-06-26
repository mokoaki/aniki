class UsersController < ApplicationController
  before_action :login_check, only: [:edit, :update, :new, :create]
  before_action :admin_check, only: [:new, :create]

  def index
    if signed_in?
      redirect_to directory_path(FileObject.get_root_object.id)
    else
      redirect_to login_path
    end
  end

  def login
  end

  def logout
    sign_out
    redirect_to login_path
  end

  def login_try
    user = User.find_by(login_id: params[:login_id].downcase)
logger.debug User.all.inspect
logger.debug user.inspect
logger.debug 1
    if user && user.authenticate(params[:password])
logger.debug 2
      logger.debug 'ログイン成功'
logger.debug 3
      sign_in user

      redirect_to root_path
    else
logger.debug 4
      logger.debug 'ログイン失敗'
logger.debug 5
      flash.now[:error] = 'パス違くね？'

      render :login
    end
  end

  def edit
    @user = current_user
  end

  def update
    user = current_user
    user.update_attributes(user_params)

    flash[:notice] = 'おｋ'
    redirect_to edit_user_path
  end

  def new
    @user = User.new
  end

  def create
    User.create(user_params)
    flash[:notice] = 'おｋ'
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
