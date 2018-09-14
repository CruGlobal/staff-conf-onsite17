class Conference < ApplicationRecord
  include Monetizable

  acts_as_list
  has_paper_trail

  monetize_attr :price_cents, numericality: {
    greater_than_or_equal_to: -1_000_000,
    less_than_or_equal_to:     1_000_000
  }

  has_many :conference_attendances, dependent: :destroy
  has_many :attendees, through: :conference_attendances

  validates :name, presence: true
  validates :staff_conference, inclusion: { in: [true, false] }
  validates :start_at, :end_at, presence: true

  after_save :only_one_staff_conference!

  class << self
    def staff_conference
      find_by!(staff_conference: true)
    end
  end

  def to_s
    name
  end

  def audit_name
    "#{super}: #{self}"
  end

  private

  def only_one_staff_conference!
    return unless staff_conference_changed? && staff_conference?

    self.class.
      where.not(id: id).where(staff_conference: true).
      find_each { |c| c.update!(staff_conference: false) }
  end
end
