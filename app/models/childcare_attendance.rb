class ChildcareAttendance < ApplicationRecord
  belongs_to :childcare
  belongs_to :child

  validates :child_id, uniqueness: {
    scope: :childcare_id, message: 'may only sign up for a class once'
  }
end
