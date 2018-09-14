# The security policy for accessing {HousingFacility} records.
class HousingFacilityPolicy < AdminOnlyPolicy
  def import?
    create?
  end
end
