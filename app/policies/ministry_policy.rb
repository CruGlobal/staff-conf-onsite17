# The security policy for accessing {Ministry} records.
class MinistryPolicy < AdminOnlyPolicy
  def import?
    create?
  end
end
