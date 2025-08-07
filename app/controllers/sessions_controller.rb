class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email].downcase)
    if user&.authenticate(params[:password]) && user.role != "admin"
      session[:user_id] = user.id
      redirect_to user, notice: "Logged in!"
    else
      flash.now[:alert] = "Invalid email/password combination"
      render :new
    end
  end
  def new

  end
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out!"
  end
end
