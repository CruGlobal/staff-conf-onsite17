class FacilityUseFee::ChargeAttendeeCost < ChargesService
  attr_accessor :attendee

  def call
    assign_totals(
      ApplyCostAdjustments.call(charges: sum.charges,
                                cost_adjustments: sum.cost_adjustments)
    )
  end

  def sum
    @sum ||= FacilityUseFee::SumAttendeeCost.call(attendee: attendee)
  end
end
