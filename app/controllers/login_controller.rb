class LoginController < ApplicationController
  skip_before_action :authenticate_user!, only: :missing

  # The user has successfully logged into the remote CAS service, but this
  # system does not have an account setup for that user. An existing user
  # (role: admin) will have to create an accoun for them first.
  def unauthorized
    @email = session_user.cas_email
  end
end
