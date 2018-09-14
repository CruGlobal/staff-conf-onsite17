class ApplicationController < ActionController::Base
  include Authenticatable

  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit

  helper_method :current_user
end
