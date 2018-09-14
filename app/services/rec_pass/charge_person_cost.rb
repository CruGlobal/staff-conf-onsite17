class RecPass::ChargePersonCost < ChargesService
  attr_accessor :person

  def call
    assign_totals(
      ApplyCostAdjustments.call(charges: sum.charges,
                                cost_adjustments: sum.cost_adjustments)
    )
  end

  def sum
    @sum ||= RecPass::SumPersonCost.call(person: person)
  end
end
