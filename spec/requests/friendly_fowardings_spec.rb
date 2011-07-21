require 'spec_helper'

describe "FriendlyFowardings" do
  it "should foward to the required page after signin" do
    user=Factory(:user)
    visit edit_user_path(user)
    #the test automatically redirect to the sign in page
    fill_in :email, :with=>user.email
    fill_in :password, :with=>user.password
    click_button
    #the test follows the redirect again, this time to users/edit
    response.should render_template("users/edit")
  end
end
