class ConferenceAttendance < ApplicationRecord
  belongs_to :conference
  belongs_to :attendee

  validates :attendee_id, uniqueness: {
    scope: :conference_id, message: 'may only sign up for a conference once'
  }

  delegate :seminary, to: :attendee
end
