require 'test_helper'

class TestApplicationController < ApplicationController
  before_action :authenticate_user!, only: :test_action

  def test_action
    head :ok
  end
end


class TestApplicationControllerTest < ControllerTestCase
  setup do
    @first_name = 'Foo'
    @last_name = 'Bar'
    @email = 'foo-bar@example.com'
    @guid = 'test-guid'

    # We use :eval_block instead of :draw, so existing routes aren't removed
    Rails.application.routes.send :eval_block,
      proc { get 'test_action' => 'test_application#test_action' }
  end

  # Scenario: the user has successfully logged in to the remote CAS service and
  # they exist in the Users table.
  test 'login with CAS' do
    @user = create :user, email: @email, guid: @guid

    refute @controller.current_user, 'user should not be logged in'

    @request.session['cas'] = {
      'user' => @email,
      'extra_attributes' => {
        'ssoGuid' => @guid,
        'firstName' => @first_name,
        'lastName' => @last_name
      }
    }

    get :test_action

    assert_equal @user, @controller.current_user.reload

    assert_equal @first_name, @controller.current_user.first_name
    assert_equal @last_name, @controller.current_user.last_name
    assert_equal @email, @controller.current_user.email
    assert_equal @guid, @controller.current_user.guid
  end

  # Scenario: the user has successfully logged in to the remote CAS service but
  # they don't exist in the Users table
  test 'failed login with CAS' do
    @user = create :user, email: @email

    refute @controller.current_user, 'user should not be logged in'

    @request.session['cas'] = {
      'user' => 'some_other_email@example.com',
      'extra_attributes' => {
        'ssoGuid' => @guid,
        'firstName' => @first_name,
        'lastName' => @last_name
      }
    }

    get :test_action

    assert_redirected_to controller: 'login', action: 'unauthorized'
  end

  # Scenario: the user has not logged in to the remote CAS service
  test 'not logged into CAS' do
    @user = create :user, email: @email

    refute @controller.current_user, 'user should not be logged in'

    @request.session['cas'] = {}

    get :test_action

    assert_response :unauthorized
  end
end
