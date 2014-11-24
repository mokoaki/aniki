class UsersController < ApplicationController
  before_action :login_check, only: [:edit, :update, :new, :create]
  before_action :admin_check, only: [:new, :create]

  def login
  end

  def login_try
    user = User.find_by(login_id: params[:login_id].downcase)

    if user && user.authenticate(params[:password])
      sign_in user

      redirect_to root_path
    else
      flash.now[:error] = 'ログイン失敗'

      render :login
    end
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update_attributes(user_params)
      redirect_to root_path
    else
      @user = User.find_by(id: params[:id])
      @user[:login_id] = user_params[:login_id]
      flash.now[:error] = "失敗した 英語読んでね → #{current_user.errors.messages}"
      render :edit
    end
  end

  def new
    @user = User.new
    render :edit
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      @user.save
      redirect_to root_path
    else
      flash.now[:error] = "失敗した 英語読んでね → #{@user.errors.messages}"
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
