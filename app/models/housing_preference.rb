class HousingPreference < ApplicationRecord
  HOUSING_TYPE_FIELDS = {
    roommates: %i[dormitory].freeze,
    beds_count: %i[dormitory].freeze,
    single_room: %i[dormitory].freeze,

    children_count: %i[apartment].freeze,
    bedrooms_count: %i[apartment].freeze,
    other_family: %i[apartment].freeze,
    accepts_non_air_conditioned: %i[apartment].freeze,

    location1: %i[apartment dormitory].freeze,
    location2: %i[apartment dormitory].freeze,
    location3: %i[apartment dormitory].freeze
  }.freeze

  enum housing_type: %i[dormitory apartment self_provided]

  belongs_to :family, inverse_of: :housing_preference

  validates :family, :housing_type, presence: true
  validates :children_count, :bedrooms_count,
            allow_nil: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
