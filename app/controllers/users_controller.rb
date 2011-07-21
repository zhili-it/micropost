class UsersController < ApplicationController
  before_filter :authenticate, :only=>[:edit,:update,:index,:destroy]
  before_filter :correct_user, :only=>[:edit,:update]
  before_filter :admin_user, :only=>[:destroy]
  
  def index
    @title="All users"
    @users = User.paginate(:page => params[:page])
  end
  
  def new
    if signed_in?
      flash[:notice]="You are already a VIP "
      redirect_to(root_path)
    else
      @user=User.new
      @title="Sign up"
    end
  end
  
  def show
    @user=User.find(params[:id])
    @title=@user.name
  end
  
  def create
    @user=User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success]="welcome to Ray's micropost"
      redirect_to @user
    else
      @title="Sign up"
      @user.password=""
      @user.password_confirmation=""
      render 'new' 
    end
  end
  
  def edit
    @title="Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success]="User information has been updated"
      redirect_to @user
    else
      @title="Edit user"
      render 'edit'
    end    
  end
  
  def destroy
    user=User.find(params[:id])
    if user.admin?
      flash[:notice]="You cannot delete yourself"
    else
      user.destroy
      flash[:success]="User deleted"
    end
      redirect_to users_path
  end
  
  private 
    def authenticate
      deny_access unless signed_in?
    end
    
    def correct_user
      @user=User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
