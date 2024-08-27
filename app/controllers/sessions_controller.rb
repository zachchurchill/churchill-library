class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:session][:username].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to root_path
    else
      flash.now[:danger] = "Invalid username/password combination"
      render "new"
    end
  end

  def delete
    log_out
    redirect_to root_path
  end
end
