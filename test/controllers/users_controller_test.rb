require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = users(:staff)
    @admin = users(:admin)
    @bob = users(:bob)
  end

  test "index can bew viewed by admin" do
    sign_in_as(@admin.username)
    get users_url
    assert_response :success
  end

  test "index cannot be viewed by staff" do
    sign_in_as(@staff.username)
    get users_url
    assert_redirected_to root_url
  end

  test "new can be viewed by admin" do
    sign_in_as(@admin.username)
    get new_user_url
    assert_response :success
  end

  test "new cannot be viewed by staff" do
    sign_in_as(@staff.username)
    get new_user_url
    assert_redirected_to root_url
  end

  test "admin can create a user" do
    sign_in_as(@admin.username)
    assert_difference('User.count') do
      post users_url, params: { user: { admin: true, password: 'secret', password_confirmation: 'secret', username: 'user3' } }
    end

    assert_redirected_to users_url
  end

  test "staff cannot create a user" do
    sign_in_as(@staff.username)
    assert_no_difference('User.count') do
      post users_url, params: { user: { admin: true, password: 'secret', password_confirmation: 'secret', username: 'user3' } }
    end

    assert_redirected_to root_url
  end

  test "admin should get edit form for other users" do
    sign_in_as(@admin.username)
    get edit_user_url(@staff)
    assert_response :success
  end

  test "staff should not get edit form for other users" do
    sign_in_as(@staff.username)
    get edit_user_url(@admin)
    assert_redirected_to root_url
  end

  test "staff should get edit form for self" do
    sign_in_as(@staff.username)
    get edit_user_url(@staff)
    assert_response :success
  end

  test "admin should be able to update user" do
    sign_in_as(@admin.username)
    patch user_url(@bob), params: { user: { admin: true, username: @bob.username } }
    @bob.reload
    assert @bob.admin
    assert_redirected_to users_url
  end

  test "staff should not be able to update user" do
    sign_in_as(@staff.username)
    patch user_url(@bob), params: { user: { id: @bob.id, username: @bob.username } }
    assert_redirected_to root_url
  end

  test "staff should be able to update self" do
    sign_in_as(@staff.username)
    patch user_url(@staff), params: { user: { id: @staff.id, username: 'staff2' } }

    @staff.reload
    assert_equal 'staff2', @staff.username
    
    assert_redirected_to root_url
  end

  test "admin should be able to destroy user" do
    sign_in_as(@admin.username)

    assert_difference('User.count', -1) do
      delete user_url(@bob)
    end

    assert_redirected_to users_url
  end

  test "staff should not be able to destroy user" do
    sign_in_as(@staff.username)

    assert_no_difference('User.count') do
      delete user_url(@bob)
    end

    assert_redirected_to root_url
  end
end
