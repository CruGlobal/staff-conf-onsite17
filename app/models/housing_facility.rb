class HousingFacility < ApplicationRecord
  has_paper_trail

  enum housing_type: %i[dormitory apartment self_provided]

  belongs_to :cost_code
  has_many :housing_units, dependent: :destroy

  validates :cost_code, presence: true

  delegate :min_days, :max_days, to: :cost_code

  scope :dormitories, -> { where(housing_type: HousingFacility.housing_types[:dormitory]) }
  scope :apartments,  -> { where(housing_type: HousingFacility.housing_types[:apartment]) }

  class << self
    def cafeterias
      distinct.pluck(:cafeteria).compact.sort
    end
  end

  def audit_name
    "#{super}: #{name}"
  end

  def on_campus
    self[:on_campus].present? ? self[:on_campus] : dormitory?
  end
  alias on_campus? on_campus

  def to_s
    name
  end
end
