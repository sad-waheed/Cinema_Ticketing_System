class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user, :logged_in?, :current_admin, :admin_logged_in?
  include Pagy::Backend

  # ADMIN HELPERS
  def current_admin
    # Fetch user from session if role is admin
    @current_admin ||= begin
                         user = User.find_by(id: session[:admin_user_id])
                         user if user&.role == 'admin'
                       end
  end

  def admin_logged_in?
    current_admin.present?
  end

  def require_admin_login
    redirect_to new_admin_session_path, alert: "You must be logged in as admin" unless admin_logged_in?
  end

  # USER HELPERS
  def current_user
    # Fetch user from session if role is user (or not admin)
    @current_user ||= begin
                        user = User.find_by(id: session[:user_id])
                        user if user && user.role != 'admin' # only non-admins count as normal users
                      end
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to new_session_path, alert: "Please log in first" unless logged_in?
  end

end

