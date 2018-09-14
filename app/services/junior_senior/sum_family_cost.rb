class JuniorSenior::SumFamilyCost < ChargesService
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
    children.map { |child| JuniorSenior::ChargeChildCost.call(child: child) }
  end

  def children
    family.children.reject { |c| c.age_group == :childcare }
  end
end
