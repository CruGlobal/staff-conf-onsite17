# This concern will set a record's +last_name+ attribute to its associated
# {Family Family's} +last_name+ attribute, if it's not otherwise specified.
module FamilyMember
  extend ActiveSupport::Concern

  included do
    before_validation :default_to_family_name, on: :create
  end

  private

  def default_to_family_name
    self.last_name = family.last_name if last_name.blank? && family
  end
end
