class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:session][:username].downcase)
    if user&.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def delete
  end
end
