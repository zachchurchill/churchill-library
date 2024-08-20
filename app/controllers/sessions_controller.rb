class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:session][:username].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to root_url
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def delete
  end
end
