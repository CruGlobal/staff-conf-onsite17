class CostCodeCharge < ApplicationRecord
  include Monetizable

  belongs_to :cost_code, inverse_of: :charges

  monetize_attr :adult_cents, :teen_cents, :child_cents, :infant_cents,
                :child_meal_cents, :single_delta_cents, numericality: {
                  greater_than_or_equal_to: -1_000_000,
                  less_than_or_equal_to:     1_000_000
                }

  validates :cost_code_id, presence: true
  validates :max_days, uniqueness: { scope: :cost_code_id }
end
