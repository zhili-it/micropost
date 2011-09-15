require 'spec_helper'

describe UsersController do
  render_views
  
  describe "Delete 'destroy'" do
    before(:each) do
      @user=Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id=>@user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      before(:each) do
        test_sign_in(@user)
      end
      it "should protect the page" do
        delete :destroy, :id=>@user
        response.should redirect_to(root_path)
      end
      
    end
    
    describe "as an admin user" do
      before (:each) do
        @admin=Factory(:user,:email=>"admin@example.com",:admin=>true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id=>@user
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to Users page" do
        delete :destroy, :id=>@user
        response.should redirect_to(users_path)
      end
      
      it "should not delete admin user itself" do
        lambda do
          delete :destroy, :id=>@admin
        end.should_not change(User,:count)
      end
    end
  end
  
  describe "GET 'index'" do
    describe "for non signin users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "for signin users" do
      before (:each) do
        @user=test_sign_in(Factory(:user))
        second=Factory(:user,:email=>"second@test.com")
        third=Factory(:user, :email=>"third@test.com")
        @users=[@user,second,third]
        30.times do
          @users<< Factory(:user,:email=>Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have a right title" do
        get :index
        response.should have_selector("title",:content=>"All users")
      end
      
      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content=>user.name)
        end
      end
      
      it "should paginate user" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled",:content=>"Previous")
        response.should have_selector("a",:href=>"/users?page=2",:content=>"2")
        response.should have_selector("a", :href=>"/users?page=2",:content=>"Next")
      end
      
      describe "as a normal user" do
        it "should not have a 'delete' link for each user" do
          get :index
          @users.each do |user|
            response.should_not have_selector("a",:comtent=>"Delete")
          end
        end
      end
      
      describe "as a admin user" do
        it "should have 'delete' link for each user" do
          admin=Factory(:user,:email=>"admin@example.com",:admin=>true)
          test_sign_in(admin)
          get :index
          @users.each do |user|
            response.should have_selector("a",:content=>"Delete")
          end
        end
      end
    end
    
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title 'Sign up'" do
      get :new
      response.should have_selector("title",:content=>"Sign up")
    end
    
    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end
    
    it "should have a email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end
    
    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end
    
    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
  end
  
  describe "GET 'show'" do
    before(:each) do
      @user=Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id=>@user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id=>@user
      assigns(:user).should==@user
    end
    
    it "should have the right title" do
      get :show, :id=>@user
      response.should have_selector("title",:content=>@user.name)
    end
    
    it "should include user's name" do
      get :show, :id=>@user
      response.should have_selector("h1",:content=>@user.name)
    end
    
    it "should have a profile image" do
      get :show, :id=>@user
      response.should have_selector("h1>img",:class=>"gravatar")
    end
    
    it "should show the user's posts" do
      p1=Factory(:post,:user=>@user,:content=>"Foo bar")
      p2=Factory(:post,:user=>@user,:content=>"Bar stupid")
      get :show, :id=>@user
      response.should have_selector("span.content",:content=>p1.content)
      response.should have_selector("span.content", :content=>p2.content)
    end
    
    describe "user info in sidebar" do
      it "should show the number of user's posts" do
        p1=Factory(:post,:user=>@user,:content=>"Foo bar")
        p2=Factory(:post,:user=>@user,:content=>"Bar stupid")
        p3=Factory(:post,:user=>@user,:content=>"hello stupid")
        get :show, :id=>@user
        response.should have_selector("span.posts",:content=>"3 posts")
      end
      
      it "should show 'post' if user has only one post" do
        p1=Factory(:post,:user=>@user,:content=>"Foo bar")
        get :show, :id=>@user
        response.should have_selector("span.posts", :content=>"1 post")
      end
      
      it "should show 'post' if user has more than one posts" do
        p1=Factory(:post,:user=>@user,:content=>"Foo bar")
        p2=Factory(:post,:user=>@user,:content=>"Bar stupid")
        get :show, :id=>@user
        response.should have_selector("span.posts",:content=>"2 posts")
      end
    end
    
    
  end
  
  describe "post 'create'" do
    
    describe "failure" do
      before(:each) do
        @attr={:name=>"",:email=>"",:password=>"",:password_confirmation=>""}
      end
    
      it "should not create a new user" do
        lambda do
          post :create, :user=>@attr
        end.should_not change(User, :count)
      end
    
      it "should have a right title" do
        post :create, :user=>@attr
        response.should have_selector("title",:content=>"Sign up")
      end
    
      it "should render the 'new' page" do
        post :create, :user=>@attr
        response.should render_template('new')
      end
    end
    
    describe "success" do
      before(:each) do
        @attr={:name=>"zhili",:email=>"zhili@163.com",:password=>"password",:password_confirmation=>"password"}
      end
      
      it "should create a user" do
        lambda do
          post :create, :user=>@attr
        end.should change(User,:count).by(1)
      end
      
      it "should redirect to user show page" do
        post :create, :user=>@attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post :create, :user=>@attr
        flash[:success].should =~ /welcome to Ray's micropost/i
      end
      
      it "should sign user in" do
        post :create, :user=>@attr
        controller.should be_signed_in
      end
    end
  end
  
  describe "GET 'edit" do
    before (:each) do
      @user=Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id=>@user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id=>@user
      response.should have_selector("title", :content=>"Edit user")
    end
    
    it "should have a link to change Gravatar" do
      get :edit, :id=>@user
      gravatar_url="http://gravatar.com/emails"
      response.should have_selector("a",:href=>gravatar_url,:content=>"change")
    end
  end
  
  describe "PUT 'update'" do
    before (:each) do
      @user=Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before (:each) do
        @attr={:name=>"",:email=>"",:password=>"",:password_confirmation=>""}
      end
      
      it "should render the 'edit' page" do
        put :update, :id=>@user, :user=>@attr
        response.should render_template('edit')
      end
      
      it "should hava a right title" do
        put :update, :id=>@user, :user=>@attr
        response.should have_selector("title", :content=>"Edit user")
      end
    end
    
    describe "success" do
      before(:each) do
        @attr={:name=>"new",:email=>"new@test.com",:password=>"password",:password_confirmation=>"password"}
      end
      
      it "should change user's attributes" do
        put :update, :id=>@user, :user=>@attr
        @user.reload
        @user.name.should==@attr[:name]
        @user.email.should==@attr[:email]
      end
      
      it "should redirect to user's show page" do
        put :update, :id=>@user, :user=>@attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put :update, :id=>@user, :user=>@attr
        flash[:success].should=~ /updated/
      end
      
    end
    
  end
  
  describe "authentication of update/edit pages" do
    before(:each) do
      @user=Factory(:user)
    end
    
    describe "for non-signin-user" do
      it "should deny access to 'edit'" do
        get :edit, :id=>@user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'update " do
        put :update, :id=>@user, :user=>{}
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signin user" do
      before(:each) do
        wrong_user=Factory(:user,:email=>"wrong_user@test.com")
        test_sign_in(wrong_user)
      end
      
      it "should require matching user for 'edit'" do
        get :edit, :id=>@user
        response.should redirect_to(root_path)
      end
      
      it "should require matching user for 'update" do
        put :update, :id=>@user, :user=>{}
        response.should redirect_to(root_path)
      end
    end
  end

end
