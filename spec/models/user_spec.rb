require 'spec_helper'

describe User do
  before (:each) do
    @attr={:name=>"zhili",
           :email=>"zhili@163.com",
           :password=>"password",
           :password_confirmation=>"password"}
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user=User.new(@attr.merge(:name=>""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
    no_email_user=User.new(@attr.merge(:email=>""))
    no_email_user.should_not be_valid
  end
  
  it "should reject the name that is longer than 50 chars" do
    long_name="a"*51
    long_name_user=User.new(@attr.merge(:name=>long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp] 
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end 
  end
  
  it "should reject invalid email addresses" do 
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.] 
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    #put a user with given email address into database
    User.create!(@attr)
    user_with_duplicate_email=User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email address identical up to case" do
    User.create!(@attr.merge(:email=>@attr[:email].upcase))
    user_with_duplicate_email=User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validation" do
    it "should require a password" do
      User.new(@attr.merge(:password=>"",:password_confirmation=>"")).
      should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation=>"invlid")).
      should_not be_valid
    end
    
    it "should reject a password that is shorter than 6 chars" do
      pw="a"*5
      User.new(@attr.merge(:password=>pw,:password_confirmation=>pw)).
      should_not be_valid
    end
    
    it "should reject a password that is longer than 40 chars" do
      pw="a"*41
      User.new(@attr.merge(:password=>pw,:password_confirmation=>pw)).
      should_not be_valid
    end
  end
  
  describe "password encryption" do
    before(:each) do
      @user=User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "matching_password? method" do
      it "should be true if the passwords match" do
        @user.matching_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.matching_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        wrong_password_user=User.authenticate(@attr[:email],"xxpassword")
        wrong_password_user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        nonexistent_user=User.authenticate("nouser@gmail.com",@attr[:password])
        nonexistent_user.should be_nil
      end
      
      it "should return the user on email/password match" do
        matching_user=User.authenticate(@attr[:email],@attr[:password])
        matching_user.should==@user
      end
    end
    
  end
  
  describe "admin attribute" do
    before (:each) do
      @user=User.create!(@attr)
    end
    
    it "should response to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "post associations" do
    before (:each) do
      @user=User.create(@attr)
      @p1=Factory(:post,:user=>@user, :created_at=>1.day.ago)
      @p2=Factory(:post, :user=>@user, :created_at=>1.hour.ago)
    end
    
    it "should have a posts attribute" do
      @user.should respond_to(:posts)
    end
    
    it "should have the right post in the right order" do
      @user.posts.should==[@p2,@p1]
    end
    
    it "should destroy associated posts" do
      @user.destroy
      [@p1,@p2].each do |post|
        Post.find_by_id(post.id).should be_nil 
      end
    end
    
    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's posts" do
        @user.feed.include?(@p1).should be_true
        @user.feed.include?(@p2).should be_true
      end
      
      it "should not include different user's posts" do
        p3=Factory(:post, :user=>Factory(:user,:email=>Factory.next(:email)))
        @user.feed.include?(p3).should be_false
      end
    end
  end
end
