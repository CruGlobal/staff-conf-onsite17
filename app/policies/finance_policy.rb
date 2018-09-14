# Policy classes that extend this one will only allow Finance and Admin users
# to Create, Update, or Destroy records. General users will still be able to
# read these records.
class FinancePolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    show?
  end

  def update?
    user.finance? || user.admin?
  end

  def create?
    update?
  end

  def destroy?
    update?
  end

  def scope
    record.class
  end
end
