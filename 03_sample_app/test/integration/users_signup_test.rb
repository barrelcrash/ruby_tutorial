require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
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

  test "valid signup information" do
    get signup_path
    assert_select 'form[action="/signup"]'
    assert_difference 'User.count', 1 do
      post signup_path, params: {
        user: {
          name: "test test",
          email: "user@valid.com",
          password: "test123",
          password_confirmation: "test123"
        }
      }
    end
    follow_redirect!
    assert_not flash.empty?
    assert_template 'users/show'
    assert is_logged_in?
  end
end
