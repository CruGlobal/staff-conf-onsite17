class Attendee < Person
  include FamilyMember

  CONFERENCE_STATUS_CHECKED_IN = 'Checked-In'.freeze
  CONFERENCE_STATUS_ACCEPTED = [
    'Exempt',
    CONFERENCE_STATUS_CHECKED_IN,
    'Cru17 Not Required'
  ].freeze

  CONFERENCE_STATUSES =
    (%w[Registered Expected] + CONFERENCE_STATUS_ACCEPTED).freeze

  after_initialize :set_default_seminary
  before_save :touch_conference_status_changed, if: :conference_status_changed?

  belongs_to :family
  belongs_to :seminary

  has_many :conference_attendances, dependent: :destroy
  has_many :conferences, through: :conference_attendances
  has_many :course_attendances, dependent: :destroy
  has_many :courses, through: :course_attendances

  accepts_nested_attributes_for :course_attendances, allow_destroy: true
  accepts_nested_attributes_for :meal_exemptions, allow_destroy: true

  validates :family_id, presence: true
  validates :conference_status, presence: true
  validates_associated :course_attendances, :meal_exemptions

  def conference_names
    conferences.pluck(:name).join(', ')
  end

  def check_in!
    unless checked_in?
      self.conference_status = CONFERENCE_STATUS_CHECKED_IN
      save(validate: false)
    end
  end

  def checked_in?
    CONFERENCE_STATUS_ACCEPTED.include?(conference_status)
  end

  def no_dates?
    arrived_at.blank? && departed_at.blank? && stays.empty?
  end

  def exempt?
    conference_status == 'Exempt'
  end

  protected

  def set_default_seminary
    self.seminary_id ||= Seminary.default&.id
  end

  def touch_conference_status_changed
    self.conference_status_changed_at = Time.zone.now
  end
end
