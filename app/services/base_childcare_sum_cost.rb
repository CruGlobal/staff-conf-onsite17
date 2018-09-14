class BaseChildcareSumCost < ChargesService
  attr_accessor :child

  def call
    charges[age_group] += week_charges.values.inject(Money.empty, :+)
    charges[age_group] += deposit_charge

    self.cost_adjustments = child.cost_adjustments
  end

  # @return Hash[Integer, Money] a map of week numbers to the child's fee for
  #   that week
  def week_charges
    @week_charges ||=
      Hash[child.childcare_weeks.map { |index| [index, charge(index)] }]
  end

  def deposit_charge
    if child.childcare_deposit?
      UserVariable[:childcare_deposit]
    else
      Money.empty
    end
  end

  protected

  # The only difference in calculating this cost between "children" and
  # "juniors and seniors" is the +UserVariable+ used for the weekly rate.
  def age_group
    raise NotImplementedError
  end

  private

  def charge(index)
    UserVariable[age_group_symbol("week_#{index}")]
  end

  def age_group_symbol(suffix)
    format('%s_%s', age_group, suffix).to_sym
  end
end
