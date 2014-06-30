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

    if user && user.authenticate(params[:password])
      flash[:notice] = 'ログイン成功'
      sign_in user

      redirect_to root_path
    else
      flash.now[:error] = 'ログイン失敗'

      render :login
    end
  end

  def edit
    flash.now[:notice] = 'ユーザ情報更新'
    @user = current_user
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = '更新した'
      redirect_to root_path
    else
      @user = User.find_by(id: params[:id])
      @user.login_id = user_params[:login_id]
      flash[:error] = '失敗した'
      render :edit
    end
  end

  def new
    flash.now[:notice] = 'ユーザ新規作成'
    @user = User.new
    render :edit
  end

  def create
    if User.new(user_params).save
      flash[:notice] = '作成した'
      redirect_to root_path
    else
      @user = User.new(user_params)
      flash[:error] = '失敗した'
      render :edit
    end

  end

  private

  def login_check
    redirect_to(login_path) if !signed_in?
  end

  def admin_check
    redirect_to(root_path) if !current_user.admin?
  end

  def user_params
    params.require(:user).permit(:login_id, :password, :password_confirmation)
  end
end
