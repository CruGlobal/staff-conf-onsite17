# The security policy for accessing {Child} records.
class ChildPolicy < PersonPolicy
  def edit_deposit?
    user.admin? || user.finance?
  end
end
