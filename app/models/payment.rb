class Payment < ApplicationRecord
  include Monetizable

  DESCRIPTION_ATTRIBUTES = %i[comment business_unit operating_unit
                              department_code project_code reference].freeze

  monetize_attr :price_cents, numericality: {
    greater_than_or_equal_to: -1_000_000,
    less_than_or_equal_to:     1_000_000
  }
  enum payment_type: %i[
    pre_paid credit_card cash_check business_account staff_code
  ]

  enum cost_type: CostAdjustment.cost_types.keys

  belongs_to :family

  validates :family_id, :payment_type, :cost_type, :price_cents, presence: true

  # @return [String] A slash delimited list of payment details
  def description
    DESCRIPTION_ATTRIBUTES.map(&method(:send)).select(&:present?).join(' / ')
  end
end
