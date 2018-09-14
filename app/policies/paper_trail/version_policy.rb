module PaperTrail
  # The security policy for accessing {VersionPolicy} records.
  class VersionPolicy < AdminOnlyPolicy
    def show?
      user.admin? || user.finance?
    end

    def index?
      user.admin? || user.finance?
    end

    def create?
      false # these should be managed by PaperTrail
    end

    def update?
      false # these should be managed by PaperTrail
    end
  end
end
