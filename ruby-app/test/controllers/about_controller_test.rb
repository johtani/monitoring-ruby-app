require 'test_helper'

class AboutControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_about_url
    assert_response :success
  end

end
