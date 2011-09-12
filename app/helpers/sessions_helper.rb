module SessionsHelper
  def sign_in(user)
    #cookies.permanent.signed[:remember_token]=[user.id,user.salt]
    #impletement by session
    session[:current_user_id]=user.id
    #"current_user="is a setter method, user on right side is an arguement. set the signed in user to the @current_user
    current_user=user
  end
  
  def sign_out
    #cookies.delete(:remember_token)
    session[:current_user_id]=nil
    current_user=nil
  end
  
  def current_user=(user)
    @current_user=user
  end
  
  def current_user
#    @current_user||=user_from_remember_token
    @current_user||=session[:current_user_id]&&User.find(session[:current_user_id])
  end
  
  def signed_in?
    !current_user.nil?
  end
  
#  private
#  def user_from_remember_token
#    User.authenticate_with_salt(*remember_token)
#  end
  
#  def remember_token
#    cookies.signed[:remember_token]||[nil,nil]
#  end
  def authenticate
    deny_access unless signed_in? 
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :notice=>"Please sign in to access this page"
  #flash[:notice]="Please sign in to access this page"
  #redirect_to signin_path
  end
  
  def current_user?(user)
    user==current_user
  end
  
  def redirect_back_or (default)
    redirect_to(session[:location]||default)
    clear_location
  end
  
  private
  def store_location
    session[:location]=request.fullpath
  end
  def clear_location
    session[:location]=nil
  end
    
end
