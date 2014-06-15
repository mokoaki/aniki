class UsersController < ApplicationController
  def index
    if signed_in?
      redirect_to directory_path(0)
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
end
