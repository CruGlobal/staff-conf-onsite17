# This is the base class for all services which sum up the fees to be charged
# to a family. These services are used in conjunction with
# [ApplyCostAdjustments] to accurately total their charges, taking into account
# the various "cost types" involved.
class ChargesService < ApplicationService
  # +Hash<Symbol, Money>+
  #   A map of cost types to the fee accrued for that type. Each Symbol should
  #   correspond to an entry in [CostAdjustment#cost_type]
  attr_accessor :charges

  # +Array<CostAdjustment>+
  #   A list of all possible adjustments this service will consider when
  #   calculating the total. Each +CostAdjustment+ applies only to a single
  #   "cost type," so some adjustments may not be applicable, if have been no
  #   charges of that type.
  attr_accessor :cost_adjustments

  # +Money+
  #   The total dollar-amount of all applicable +#cost_adjustments+. This
  #   figure includes ercentage-based adjustments which have been calculated
  #   based off the +#subtotal+
  attr_accessor :total_adjustments

  # +Money+
  #   The total of all charges, before the {CostAdjustment cost adjustments} are
  #   applied
  attr_accessor :subtotal

  # +Money+
  #   The total of all charges, after the {CostAdjustment cost adjustments} are
  #   applied
  attr_accessor :total

  after_initialize :default_values

  # Copy the values from another +ChargesService+.
  #
  # @param other [ChargesService]
  def assign_totals(other)
    self.total_adjustments = other.total_adjustments
    self.subtotal = other.subtotal
    self.total = other.total
    self.cost_adjustments = other.cost_adjustments
  end

  private

  def default_values
    self.charges ||= Hash.new { |h, v| h[v] = Money.empty }
    self.cost_adjustments ||= []

    self.total_adjustments ||= Money.empty
    self.subtotal ||= Money.empty
    self.total ||= Money.empty
  end
end
