class Admin::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email].downcase)
    if user&.authenticate(params[:password]) && user.role == "admin"
      session[:admin_user_id] = user.id
      redirect_to admin_movies_path
    else
      flash[:notice] = "Invalid email/password combination"
      render :new
    end

  end
  def new

  end

  def destroy
    session.clear
    redirect_to new_admin_session_path, notice: "Logged out!"
  end
end