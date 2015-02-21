class RootController < ApplicationController
  before_action do
    redirect_to(login_path) if !signed_in?
  end

  def index
    redirect_to directory_path('root') if params[:id_hash].blank?
  end
end
