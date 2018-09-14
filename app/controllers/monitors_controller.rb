class MonitorsController < ApplicationController
  skip_before_action :authenticate_user!, only: :service_online

  def service_online
    render text: 'OK', layout: false
  end
end
