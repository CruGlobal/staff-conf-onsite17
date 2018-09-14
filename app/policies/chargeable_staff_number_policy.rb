# The security policy for accessing {ChargeableStaffNumber} records.
class ChargeableStaffNumberPolicy < FinancePolicy
  def import?
    create?
  end
end
