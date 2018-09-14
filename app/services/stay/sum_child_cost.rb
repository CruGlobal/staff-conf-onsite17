class Stay::SumChildCost < ChargesService
  attr_accessor :child

  def call
    charges[:dorm_child] +=
      dorm_stays.map { |stay| stay_charge(stay) }.inject(Money.empty, &:+)
    self.cost_adjustments = child.cost_adjustments
  end

  private

  def stay_charge(stay)
    Stay::SingleChildDormitoryCost.call(child: child, stay: stay).total
  end

  def dorm_stays
    child.stays.select { |s| s.housing_type == 'dormitory' }
  end
end
