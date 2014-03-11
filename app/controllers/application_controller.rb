class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_admin!
    is_admin = current_user.try(:admin?) || false
    redirect_to root_path, alert: "You are not authorized" unless is_admin
    return is_admin
  end
end
