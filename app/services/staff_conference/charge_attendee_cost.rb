class StaffConference::ChargeAttendeeCost < ChargesService
  attr_accessor :attendee

  def call
    sum = StaffConference::SumAttendeeCost.call(attendee: attendee)

    assign_totals(
      ApplyCostAdjustments.call(charges: sum.charges,
                                cost_adjustments: sum.cost_adjustments)
    )
  end
end
