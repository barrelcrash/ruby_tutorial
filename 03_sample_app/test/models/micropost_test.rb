require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    refute @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    refute @micropost.valid?
  end

  test "content should be no more than 140 characters" do
    @micropost.content = "a" * 141
    refute @micropost.valid?
  end
end
