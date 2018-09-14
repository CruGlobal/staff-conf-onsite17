class Stay < ApplicationRecord
  HOUSING_TYPE_FIELDS = {
    single_occupancy: [:dormitory].freeze,
    no_bed: [:dormitory].freeze,
    no_charge: [:apartment].freeze,
    waive_minimum: [:apartment].freeze,
    percentage: [:apartment].freeze
  }.freeze

  belongs_to :person
  belongs_to :housing_unit
  delegate :housing_facility, to: :housing_unit

  attr_accessor :housing_facility_id
  attr_writer :housing_type, :housing_unit_id_value

  validates :person_id, :arrived_at, :departed_at, presence: true
  validates :percentage, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  validate :no_more_than_max_days!

  scope :for_date, (lambda do |date|
    where('arrived_at <= ? AND departed_at >= ?', date, date)
  end)

  scope :in_dormitory, -> { where(housing_unit: HousingUnit.in_dormitory) }
  scope :on_campus, -> { where(housing_unit: HousingUnit.on_campus) }
  scope :in_apartment, -> { where(housing_unit: HousingUnit.in_apartment) }
  scope :in_self_provided, -> { where(housing_unit: nil) }
  scope :not_in_self_provided, -> { where.not(housing_unit: nil) }

  scope :with_cafeteria, (lambda do |cafe|
    where(housing_unit: HousingUnit.with_cafeteria(cafe))
  end)

  default_scope { order :arrived_at }

  # housing_unit will be nil if housing_type == 'self_provided'
  delegate :housing_facility, to: :housing_unit, allow_nil: true

  # housing_unit will be nil if housing_type == 'self_provided'
  delegate :housing_facility_id, to: :housing_unit, allow_nil: true

  class << self
    def min_date
      minimum(:arrived_at)
    end

    def max_date
      maximum(:departed_at)
    end

    def date_range
      min_date..max_date
    end
  end

  def housing_type
    housing_facility&.housing_type || 'self_provided'
  end

  # This is used to populate a hidden field on the formtastic form.
  def housing_unit_id_value
    housing_unit_id
  end

  def dormitory?
    housing_type == 'dormitory'
  end

  def on_campus
    housing_facility.present? && housing_facility.on_campus
  end
  alias on_campus? on_campus

  # @return [Integer] the length of the stay, in days
  def duration
    if departed_at.present? && arrived_at.present?
      [(departed_at - arrived_at).to_i, min_days].max
    else
      0
    end
  end

  def needs_bed?
    !no_bed?
  end

  # @return [Integer] if this stay is in a dormitory, the total duration of all
  #   stays in this facility, otherwise the same as {#duration}
  def total_duration
    if housing_type == 'dormitory'
      duration_of_all_dormitory_stays
    else
      duration
    end
  end

  # @return [Integer] the minimum allowed length of a stay, in days
  def min_days
    waive_minimum? ? 1 : (housing_facility&.min_days || 1)
  end

  # @return [Float] the percentage of this stay's cost which must be paid by
  #   the Attendee, expressed as a decimal between 0 and 1.
  def must_pay_ratio
    percentage / 100.0
  end

  def to_s
    where = housing_unit&.to_s || 'Self-Provided'

    format('%s, %s – %s', where, arrived_at, departed_at)
  end

  private

  def duration_of_all_dormitory_stays
    person.reload.stays.
      select { |s| s.housing_type == 'dormitory' }.
      map(&:duration).
      inject(0, &:+)
  end

  def no_more_than_max_days!
    return if housing_type == 'self_provided'

    all_stays = ([self] + person.reload.stays).uniq(&:id)
    duration = all_stays.map(&:duration).inject(&:+) || 0

    add_max_days_error(duration) if duration > housing_facility.max_days
  end

  def add_max_days_error(duration)
    errors.add(
      :departed_at,
      format('will mean that %s has stayed at this facility for a total of %d' \
             ' days: longer than the maximum allowed (%d) by the cost code, %s',
             person.full_name, duration, housing_facility.max_days,
             housing_facility.cost_code.name)
    )
  end
end
