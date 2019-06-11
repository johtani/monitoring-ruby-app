require 'test_helper'

class TroubleControllerTest < ActionDispatch::IntegrationTest
  test "should get soslow" do
    get trouble_soslow_url
    assert_response :success
  end

end
