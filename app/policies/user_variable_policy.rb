# The security policy for accessing {UserVariable} records.
class UserVariablePolicy < FinancePolicy
  def create?
    user.admin?
  end

  # {UserVariable User variables} cannot be destroyed
  def destroy?
    false
  end
end
