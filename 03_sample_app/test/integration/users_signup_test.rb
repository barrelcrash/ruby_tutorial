require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    # assert no difference before and after the block
    assert_select 'form[action="/signup"]'
    assert_no_difference 'User.count' do
      post signup_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert-danger'
  end

  test "invalid signup error messages" do
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_select 'form[action="/signup"]'
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: "test test",
          email: "user@valid.com",
          password: "test123",
          password_confirmation: "test123"
        }
      }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # try to log in pre-activation
    log_in_as(user)
    assert_not is_logged_in?

    # invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    # valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # valid activation
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    follow_redirect!
    assert_not flash.empty?
    assert_template 'users/show'
    assert is_logged_in?
  end
end
