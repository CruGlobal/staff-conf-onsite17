# Apply a series of {CostAdjustment cost adjustments} to one or more costs.
#
# The adjustments are applied in this order:
#
#   1. The percent-based adjustments are summed and subtracted from the given
#      cost. ex: $100 - ($100 * (5% + 10% + 10%)) = $75
#   2. The price-based adjustments are then summed and subtracted from that
#      result. ex: $75 - ($10 + $5) = $60
class ApplyCostAdjustments < ChargesService
  # +Hash<String, Money>+
  #   Each key is one of {CostAdjustment#cost_types} and each value is the
  #   total cost in that category. The types are used to determine which
  #   adjustments apply to each charge
  attr_accessor :charges

  # +Array<CostAdjustment>+
  attr_accessor :cost_adjustments

  # +Money+
  #   The total dollar-amount of all adjustments
  attr_accessor :total_adjustments

  # +Money+
  #   The total of all charges, before the {CostAdjustment cost adjustments} are
  #   applied
  attr_accessor :subtotal

  # +Money+
  #   The total of all charges, after the {CostAdjustment cost adjustments} are
  #   applied
  attr_accessor :total

  after_initialize :zero_totals

  def call
    charges.each(&method(:add_to_total))
    constrain_total_adjustments
  end

  private

  def zero_totals
    self.total_adjustments ||= Money.empty
    self.subtotal ||= Money.empty
    self.total ||= Money.empty
  end

  # @param type [Symbol] The cost type of the charge being added
  # @param charge [Money] The amount of money being charged
  def add_to_total(type, charge)
    type = type.to_s
    adjustments = cost_adjustments.select { |c| c.cost_type == type }
    increment_totals(charge, realize_adjustments(charge, adjustments))
  end

  # Adjusts the [#total_adjustments], [#subtotal], and [#total] based off the
  # given +charge+ and +adjust+ amounts.
  #
  # @param charge [Money] The amount of money being charged
  # @param adjust [Money] The amount to be deducted from the given charge
  def increment_totals(charge, adjust)
    self.total_adjustments += adjust
    self.subtotal += charge
    self.total += [Money.empty, charge - adjust].max
  end

  # @return [Money] The total amount of all adjustments, converting
  #   percentage-based adjuments based off the goven charge
  def realize_adjustments(charge, adjustments)
    percent_reduction = charge * total_percent(adjustments)
    price_reduction   = select_prices(adjustments).inject(Money.empty, &:+)

    [charge, percent_reduction + price_reduction].min
  end

  def total_percent(adjustments)
    select_percents(adjustments).inject(0, :+) / 100.0
  end

  def select_percents(adjustments)
    adjustments.select(&:percent?).map(&:percent)
  end

  def select_prices(adjustments)
    adjustments.select(&:price_cents?).map(&:price)
  end

  def constrain_total_adjustments
    self.total_adjustments = subtotal if total_adjustments > subtotal
  end
end
