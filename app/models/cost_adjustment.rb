class CostAdjustment < ApplicationRecord
  include Monetizable

  has_paper_trail

  monetize_attr :price_cents, allow_nil: true, numericality: {
    greater_than_or_equal_to: -1_000_000,
    less_than_or_equal_to:     1_000_000
  }

  # MPD means "Ministry Partner Development"
  enum cost_type: %i[
    dorm_adult dorm_child apartment_rent facility_use tuition_class tuition_mpd
    tuition_track tuition_staff books rec_center lunch childcare junior_senior
  ]

  belongs_to :person, foreign_key: 'person_id'

  validates :cost_type, :person, presence: true
  validates :percent, allow_nil: true, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  validate :price_and_percent_are_mutually_exclusive

  before_validation :make_zero_price_nil

  private

  def make_zero_price_nil
    self.price_cents = nil if price_cents.present? && price_cents.zero?
  end

  # Either #price or #percent must be provided, but not both
  def price_and_percent_are_mutually_exclusive
    if price_cents.present? && percent.present?
      add_mutually_exclusive_error
    elsif price_cents.nil? && percent.nil?
      errors.add(:percent, 'must be present if "price" is blank')
    end
  end

  def add_mutually_exclusive_error
    if percent_changed?
      errors.add(:percent, 'must be blank if "price" is set')
    else
      errors.add(:price_cents, 'must be blank if "percent" is set')
    end
  end
end
