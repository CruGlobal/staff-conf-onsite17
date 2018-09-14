# The security policy for accessing {Person} records.
class PersonPolicy < GeneralPolicy
  def update_family?
    true
  end
end
