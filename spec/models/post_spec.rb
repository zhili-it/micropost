require 'spec_helper'

describe Post do
  before (:each) do
    @user=Factory(:user)
    @attr={:content=>"value for content"}
  end
  
  it "should create the new instance given a valid attribute" do
    @user.posts.create!(@attr)
  end
  
  describe "user associations" do
    before (:each) do
      @post=@user.posts.create(@attr)
    end
    
    it "should have a user attribute" do
      @post.should respond_to(:user)
    end
    
    it "should have the right associated user" do
      @post.user_id.should == @user.id
      @post.user.should == @user
    end     
  end
  
  describe "validations" do
    it "should require a user id" do
      Post.new(@attr).should_not be_valid
    end
    
    it "should require nonblank content" do
      @user.posts.build(:content=>" ").should_not be_valid
    end
    
    it "should reject long content" do
      @user.posts.build(:content=>"a"*141).should_not be_valid
    end
  end
  
  describe "from users followed by" do
    before (:each) do
      @other_user=Factory(:user,:email=>Factory.next(:email))
      @third_user=Factory(:user,:email=>Factory.next(:email))
      @user_post=@user.posts.create!(:content=>"hello")
      @other_post=@other_user.posts.create!(:content=>"how")
      @third_post=@third_user.posts.create!(:content=>"are you")
      @user.follow!(@other_user)
    end
    
    it "should hava a from_users_followed_by class method" do
      Post.should respond_to(:from_users_followed_by)
    end
    
    it "should include the followed user's post" do
      Post.from_users_followed_by(@user).should include(@other_post)
    end
    
    it "should include user's own posts" do
      Post.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should not include unfollowed users posts" do
      Post.from_users_followed_by(@user).should_not include(@third_post)
    end
      
  end
end
