# The security policy for accessing {HousingUnit} records.
class HousingUnitPolicy < GeneralPolicy
  def update?
    !user.finance? && !user.read_only?
  end
end
