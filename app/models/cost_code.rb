class CostCode < ApplicationRecord
  include CostCodeHelper

  has_many :charges, class_name: 'CostCodeCharge', foreign_key: 'cost_code_id',
                     dependent: :destroy
  has_many :housing_facilities, dependent: :destroy

  accepts_nested_attributes_for :charges, allow_destroy: true

  validates_associated :charges

  # @param days [Integer] The length of the person's stay, in days
  # @return [CostCodeCharge, nil] The charges applied to a stay of the given
  #   number of days
  def charge(days:)
    charges_ordered.find_by('max_days >= ?', days)
  end

  # @return [CostCodeCharge, nil] The charge with the largest +max_days+
  def last_charge
    charges_ordered.last
  end

  # @return [Integer] The greatest +max_days+ value of all associated
  #   {CostCodeCharge charges}. Will be +0+ is there are no charges.
  def max_days
    last_charge&.max_days || 0
  end

  def to_s
    cost_code_label(self)
  end

  private

  def charges_ordered
    charges.order(:max_days)
  end
end
