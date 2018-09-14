# Policy classes that extend this one will only allow Admin users to Create,
# Update, or Destroy records. Finance and General users will still be able to
# read these records.
class AdminOnlyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    user.admin?
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
