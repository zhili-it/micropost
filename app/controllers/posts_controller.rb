class PostsController < ApplicationController
  before_filter :authenticate, :only=>[:create,:destroy]
  before_filter :authorized_user, :only=>:destroy
  
  def create
    @post=current_user.posts.build(params[:post])
    if @post.save
      flash[:success]="post created"
      redirect_to root_path
    else
 #     @feed_items=current_user.feed.paginate(:page=>params[:page])
      @feed_items=[]
      render 'pages/home'
    end
  end
  
  def destroy
    @post.destroy
    redirect_back_or root_path
  end
  
  private
    def authorized_user
      @post=Post.find(params[:id])
      redirect_to root_path unless current_user?(@post.user)
    end
end