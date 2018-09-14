# The security policy for accessing {Family} records.
class FamilyPolicy < GeneralPolicy
  def import?
    user.admin?
  end

  def show_finances?
    user.admin? || user.finance?
  end

  def checkin?
    true
  end

  def destroy?
    user.admin? || user.finance?
  end
end
