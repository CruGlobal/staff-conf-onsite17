class Stay::SingleChildDormitoryCost < ApplicationService
  NoCostCodeError = Class.new(StandardError)

  attr_accessor :child, :stay, :total

  i18n_scope :stay

  # First, for ALL dorm housing assignments (in case there's more than one),
  # add up the TOTAL number of days living in a dorm. Call this the TOTAL Days.
  #
  # For each individual child dorm housing assignment:
  #
  # 1) Calculate length of say in # days for this individual assignment:
  #    arrival date minus departure date (result must be greater than 0).
  #
  # 2) Using dorm, look up daily cost in cost code table for the TOTAL Days
  #    length of stay using the following age breakdown:
  #    Use "ADULT $/DAY" column if child's age is >=15 years old
  #    Use "TEEN $/DAY" column if child's age is >=11 <15 years old
  #    Use "CHILD $/DAY" column if (child's age is >= 5 < 11 years old AND "Needs Bed" = YES)
  #    Use "INFANT $/DAY" column if (child's age is <5 years old AND "Needs Bed" = YES)
  #    Use "CHILD MEAL ONLY $/DAY" if (child'd age is <11 and "Needs Bed" = NO)
  #
  # 3) If the "Single Occupancy" is YES, look up the "SINGLE UPCHARGE $/DAY"
  #    for this length of stay
  #
  # 4) Total cost is: individual length of stay multiplied by (daily cost +
  #    daily upcharge)
  #
  # 5) Loop through if there are multiple child dorm assignments
  def call
    self.total = stay_charge(stay)
  end

  private

  def stay_charge(stay)
    cost_code = stay.housing_facility&.cost_code

    if (charge = cost_code&.charge(days: stay.total_duration))
      daily_costs = daily_costs(child, charge, stay.single_occupancy, stay)
      (daily_costs.inject(:+) || Money.empty) * stay.duration
    else
      fail_no_cost_code!(stay, stay.duration)
    end
  end

  def daily_costs(child, charge, single, stay)
    result = Stay::ListChildCosts.call(child: child, single_occupancy: single,
                                       stay: stay)
    result.costs.compact.map { |cost| charge.send(cost) }
  end

  def fail_no_cost_code!(stay, days)
    stay = (stay.housing_facility || stay).inspect

    raise NoCostCodeError, t('errors.no_cost_code', stay: stay, duration: days)
  end
end
