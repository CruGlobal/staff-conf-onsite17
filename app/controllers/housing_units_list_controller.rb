class HousingUnitsListController < ApplicationController
  def index
    expires_in 1.hour, public: true
  end
end
