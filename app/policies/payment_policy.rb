# The security policy for accessing {Payment} records.
class PaymentPolicy < FinancePolicy
  def show?
    update?
  end
end
