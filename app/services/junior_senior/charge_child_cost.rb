class JuniorSenior::ChargeChildCost < ChargesService
  attr_accessor :child

  def call
    assign_totals(
      ApplyCostAdjustments.call(charges: sum.charges,
                                cost_adjustments: sum.cost_adjustments)
    )
  end

  def sum
    @sum ||= JuniorSenior::SumChildCost.call(child: child)
  end
end
