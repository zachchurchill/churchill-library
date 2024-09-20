module SessionsHelper
  def log_in(user)
    # Places a temporary cookie on user's browser containing
    # an encrypted version of the user's id
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate_user
    redirect_to admin_path unless logged_in?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
