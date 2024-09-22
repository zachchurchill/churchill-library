class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:session][:username].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to books_path, notice: "Welcome back, #{user.name.titlecase}!"
    else
      flash.now[:danger] = "Invalid username/password combination"
      render "new", status: :unprocessable_entity
    end
  end

  def delete
    log_out
    redirect_to root_path, notice: "Come back soon!"
  end
end
