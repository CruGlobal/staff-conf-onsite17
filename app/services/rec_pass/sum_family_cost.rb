class RecPass::SumFamilyCost < ChargesService
  attr_accessor :family

  def call
    family_costs.each do |cost|
      self.total_adjustments += cost.total_adjustments
      self.subtotal += cost.subtotal
      self.total += cost.total
    end
  end

  private

  def family_costs
    family.people.map { |p| RecPass::ChargePersonCost.call(person: p) }
  end
end
