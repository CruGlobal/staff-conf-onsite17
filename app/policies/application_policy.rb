# The superclass for all Security +Policy+ subclasses in the system. For each
# {ApplicationRecord model type}, there is a Policy class with a matching name
# that determines whether a given user can access it.
#
# +Policy+ subclasses can control whether an arbitrary {User} can *Create*,
# *Read*, *Update*, or *Destroy* records of a single type.
#
# @attr_reader user [User] The user requesting access to the given record.
# @attr_reader record [ApplicationRecord] The model object the user wants to
#   access.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # @!group Create

  # @return [Boolean] if the user may create these records
  def create?
    false
  end

  # @return [Boolean] if the user may view the creation form for these records
  def new?
    create?
  end

  # @!group Read

  # @return [Boolean] if the user may list these records
  def index?
    true
  end

  # @return [Boolean] if the user may read these records
  def show?
    scope.where(id: record.id).exists?
  end

  # @!group Update

  # @return [Boolean] if the user may update these records
  def update?
    false
  end

  # @return [Boolean] if the user may view the edit form for these records
  def edit?
    update?
  end

  # @return [Boolean] if the user may edit more than one record at a time
  def bulk_edit?
    user.admin?
  end

  # @return [Boolean] if the user may change the sort order for these records
  def reposition?
    true
  end

  # @!group Destroy

  # @return [Boolean] if the user may destroy these records
  def destroy?
    false
  end

  # @return [Boolean] if the user may destroy every record of the given type
  def destroy_all?
    destroy?
  end

  # @!endgroup

  def scope
    @scope ||= Pundit.policy_scope!(user, record.class)
  end

  Scope = Struct.new(:user, :scope) do
    def resolve
      scope
    end
  end
end
