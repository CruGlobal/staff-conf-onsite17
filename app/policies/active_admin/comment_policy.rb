module ActiveAdmin
  # The security policy for accessing +ActiveAdmin::Comment+ records.
  class CommentPolicy < GeneralPolicy
    def destroy?
      user.admin? || record.author_id == user.id
    end
  end
end
