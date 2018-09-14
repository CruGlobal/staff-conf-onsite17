# Provides the logic to authenticate the {User current user} via the remote CAS
# service.  ActiveAdmin is configured +config/initializers/active_admin.rb+ to
# call {#authenticate_user!} when no user is currently logged in.
#
# It's not enough for the end-user to have logged in successfully to the remote
# CAS service. They must also have an existing record in the {User} table.
module Authenticatable
  extend ActiveSupport::Concern

  # A {filter}[http://guides.rubyonrails.org/action_controller_overview.html#filters]
  # that checks if the user is currently logged in, on the remote CAS service,
  # and that CAS user has a {User local account} in this system.
  #
  # * If the user is not logged into CAS, they will be redirected to the CAS
  #   login page.
  # * If the logged-in user doesn't have a {User local account}, they will be
  #   shown an error message.
  def authenticate_user!
    if session_user.signed_into_cas?
      if current_user.present?
        after_successful_authentication
      else
        redirect_to unauthorized_login_path
      end
    else
      # envoke rack-cas redirect for user authentication
      head status: :unauthorized
      false
    end
  end

  # @return [User] the currently logged-in and authenticated user
  def current_user
    session_user.user_matching_cas_session
  end

  def session_user
    @session_user ||= SessionUser.new(request.session)
  end

  def after_successful_authentication
    current_user.assign_attributes(
      email: session_user.cas_email,
      first_name: session_user.cas_attr('firstName'),
      last_name: session_user.cas_attr('lastName')
    )

    current_user.save! if current_user.changed?
  end

  class SessionUser
    attr_reader :session

    def initialize(session)
      @session = session
    end

    # @return [Boolean] if the user has signed into the remote CAS service
    def signed_into_cas?
      cas_attr('ssoGuid').present?
    end

    # @return [User] the local user matching the GUID passed from the remote CAS
    #   service
    def user_matching_cas_session
      @user_matching_cas_session ||=
        if (guid = cas_attr('ssoGuid'))
          User.find_by(guid: guid)
        end
    end

    # @return [Object, nil] The value of the given attribute name from the {User
    #   current user's} data from the CAS service.
    def cas_attr(attr)
      cas_extra_attributes&.[](attr)
    end

    # @return [String, nil] The {User User's} email, from the CAS service.
    def cas_email
      session['cas']&.[]('user')
    end

    private

    def cas_extra_attributes
      session['cas']&.[]('extra_attributes')
    end
  end
end
