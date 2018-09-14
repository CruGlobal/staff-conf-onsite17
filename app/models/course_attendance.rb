class CourseAttendance < ApplicationRecord
  # enum grade: %w(AU A A- B+ B B- C+ C C- D F W)

  belongs_to :course
  belongs_to :attendee

  validates :attendee_id, uniqueness: {
    scope: :course_id, message: 'may only sign up for a class once'
  }

  delegate :seminary, to: :attendee

  def self.grades
    %w[AU A A- B+ B B- C+ C C- D F W]
  end
end
