class Course::ChargeAttendeeCost < ChargesService
  attr_accessor :attendee

  def call
    assign_totals(
      ApplyCostAdjustments.call(charges: sum.charges,
                                cost_adjustments: sum.cost_adjustments)
    )

    # We add these after the adjustments are applied, because these prices
    # aren't applicable to adjustments
    self.subtotal += sum.seminary_price
    self.total += sum.seminary_price
  end

  def sum
    @sum ||= Course::SumAttendeeCost.call(attendee: attendee)
  end
end
