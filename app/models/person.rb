class Person < ApplicationRecord
  # The possible values for the +gender+ attribute.
  GENDERS = { f: 'Female', m: 'Male' }.freeze

  FORM_OPTIONS ||= {
    # If creating a new family-member, show the family name in the title
    title: proc do |person|
      label = "#{action_name.titlecase} #{person.class.name}"

      if (family = person.family || param_family)
        "#{label} (#{family_label(family)})"
      else
        label
      end
    end
  }.freeze

  has_paper_trail

  belongs_to :family, inverse_of: :people, required: true
  belongs_to :ministry

  has_many :cost_adjustments, dependent: :destroy
  has_many :meal_exemptions, dependent: :destroy
  has_many :stays, dependent: :destroy
  has_many :housing_units, through: :stays
  has_many :housing_facilities, through: :housing_units

  scope :corbett, (lambda do
    where("housing_facilities.name LIKE 'Corbett%' OR
           housing_facilities.name LIKE 'Parmelee' OR
           conferences.name like 'Missional Team Leader%' OR
           conferences.name like 'Xtrack%' OR
           conferences.name like 'New Staff%' OR
           conferences.name like 'Colorado Operations Summer Mission'").
      joins(:conferences).
      joins(:housing_facilities)
  end)

  scope :durrell, (lambda do
    where("(housing_facilities.name LIKE 'Durward%' OR
           housing_facilities.name LIKE 'Westfall' OR
           housing_facilities.name LIKE 'Alpine' OR
           housing_facilities.name LIKE 'Pinon') AND
           conferences.name not like 'Missional Team Leader%' AND
           conferences.name not like 'Xtrack%' AND
           conferences.name not like 'New Staff%' AND
           conferences.name not like 'Colorado Operations Summer Mission'").
      joins(:conferences).
      joins(:housing_facilities)
  end)

  scope :rams_horn, (lambda do
    where("housing_facilities.name LIKE 'Summit%' OR
           housing_facilities.name LIKE 'Academic Village'").
      joins(:housing_facilities)
  end)

  scope :meal_adult, -> { where("date_part('year', age( '2017-07-01',  birthdate)) > 10") }
  scope :meal_child, (lambda do
    where("date_part('year', age( '2017-07-01',  birthdate)) > 4 AND
           date_part('year', age( '2017-07-01',  birthdate)) <= 10")
  end)
  scope :stay_date, ->(date) { where('stays.arrived_at <= :date AND stays.departed_at >= :date', date: date) }
  scope :on_campus, -> { where('housing_facilities.on_campus' => true).joins(:housing_facilities) }

  accepts_nested_attributes_for :stays, :cost_adjustments, allow_destroy: true

  after_create :ensure_primary_person

  validates :rec_pass_start_at, presence: true, if: :rec_pass_end_at?
  validates :rec_pass_end_at, presence: true, if: :rec_pass_start_at?

  validates :gender, inclusion: { in: GENDERS.keys.map(&:to_s) }
  validates_associated :stays

  def full_name
    [first_name, last_name].compact.join(' ')
  end

  def audit_name
    "#{super}: #{full_name}"
  end

  def first_name_tag
    name_tag_first_name.present? ? name_tag_first_name : first_name
  end

  def last_name_tag
    name_tag_last_name.present? ? name_tag_last_name : last_name
  end

  def full_name_tag
    [first_name_tag, last_name_tag].select(&:present?).join(' ')
  end

  def age
    @age ||= age_from_birthdate
  end

  def birthdate=(*_)
    @age = nil
    super
  end

  # @return [Boolean] if this person is staying in an
  #   {HousingFacility#on_campus on-campus facility} on the given date
  def on_campus_at?(date)
    stays.for_date(date).any?(&:on_campus?)
  end

  def rec_pass?
    rec_pass_start_at.present? && rec_pass_end_at.present?
  end

  private

  def age_from_birthdate
    return 0 if birthdate.blank?
    cutoff = UserVariable[:child_age_cutoff]

    age = cutoff.year - birthdate.year
    age -= 1 if birthday_after_date?
    age
  end

  def birthday_after_date?
    cutoff = UserVariable[:child_age_cutoff]

    birthdate.month > cutoff.month ||
      birthdate.month == cutoff.month && birthdate.day > cutoff.day
  end

  def ensure_primary_person
    if family.primary_person_id.blank? && is_a?(Attendee)
      family.update!(primary_person_id: id)
    end
  end
end
