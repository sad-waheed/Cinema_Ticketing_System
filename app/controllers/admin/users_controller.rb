class Admin::UsersController < ApplicationController

  def new
    @user = User.new
  end

  def destroy
    user = User.find(params[:id])
    if user.id != current_admin.id
      if user&.destroy()
        flash[:success] = "User deleted!"
        redirect_to admin_users_path(role: params[:role])
      else
        flash[:error] = "Something went wrong"
        redirect_to admin_users_path(role: params[:role])
      end
    else
      flash[:error] = "Cannot delete yourself!"
      redirect_to admin_users_path(role: params[:role])
    end
  end
  
  def show
    @user = User.find(params[:id])
  end

  def index
    role = params[:role]
    if (role != "admin" && role != "user")
      flash.now[:notice] = "Illegal role"
      @user = User.new
      render :new
      return
    end
    if role == "admin"
      user_scope = User.where(role: "admin")
    else
      user_scope = User.where(role: role)
    end

    if user_scope.empty?
      flash.now[:notice] = "No users found"
      @user = User.new
      render :new
      return
    end
    @pagy, @users = pagy(user_scope.order(:created_at), limit: 5)
  end



  def create
    ##create admin
    @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirmation))
    @user.role = "admin"
    if @user.save
      flash[:success] = "Admin created successfully!"
      redirect_to admin_users_path(role: "admin")
    else
      flash.now[:error] = @user.errors.full_messages
      render :new
    end
  end

end
