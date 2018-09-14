# Policy classes that extend this one will only allow all users to Create,
# Update, Read, or Destroy records.
class GeneralPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    !user.read_only?
  end

  def create?
    update?
  end

  def destroy?
    update?
  end

  def scope
    true
  end
end
