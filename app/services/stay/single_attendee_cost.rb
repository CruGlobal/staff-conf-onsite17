class Stay::SingleAttendeeCost < ApplicationService
  NoCostCodeError = Class.new(StandardError)
  NoCostTypeError = Class.new(StandardError)

  attr_accessor :stay, :type, :total

  i18n_scope :stay

  # If the housing facility for this individual assignment is an apartment,
  # look for the "DO NO CHARGE FOR THIS ASSIGNMENT" flag - if YES, the charge =
  # $0, and quit.
  #
  # For ALL dorm housing assignments (in case there's more than one), add up
  # the TOTAL number of days living in a DORM (only). Call this the TOTAL Dorm
  # Days.
  #
  # For each individual adult housing assignment:
  #   1) Calculate length of stay in # days for this individual assignment:
  #      arrival date minus departure date (result must be greater than 0)
  #
  #   2) Using Housing Facility from the assignment, determine the Cost Code.
  #
  #   3) If the housing facility is an APARTMENT, check to see if "WAIVE
  #      MINIMUM STAY" is checked. If so, go to step 4. If MINIMUM STAY for
  #      this housing facility is > length of stay, length of stay = MINIMUM
  #      STAY
  #
  #   4) Using the Cost Code, look up Adult $?/Day daily cost. A cost code may
  #      have multiple cost "groups". The correct cost group will be determined
  #      by choosing the group where the smallest Maximum Stay is >= either
  #      (the apartment individual length of stay) or (the TOTAL Dorm Days).
  #
  #   5) If the housing facility for this individual assignment is a DORM, if
  #      the "Single Occupancy" is YES, look up the "SINGLE UPCHARGE $/DAY" for
  #      this length of stay (for an apartment type, the "SINGLE UPCHARGE
  #      $/DAY" will always be $0).
  #
  #   6) Total cost is: individual length of stay X (daily cost + daily
  #      upcharge)
  #
  #   7) If the housing facility for this individual assignment is an
  #      apartment, multiply the total cost by the %COST THE OCCUPANT MUST PAY
  #
  # The final output is the resulting dollar amount.
  def call
    type, total = sum_stay_cost(stay)
    self.type = type
    self.total = total || Money.empty
  end

  private

  def sum_stay_cost(stay)
    return if stay.housing_type == 'self_provided'

    daily_cost = sum_daily_cost(stay)

    if (type = charge_type(stay))
      [type, must_pay(stay, daily_cost * stay.duration)]
    else
      fail_no_charge_type!(stay)
    end
  end

  def sum_daily_cost(stay)
    cost_code = stay.housing_facility&.cost_code

    return Money.empty if stay.no_charge?

    if (charge = cost_code&.charge(days: stay.total_duration))
      if stay.housing_type == 'dormitory' && stay.single_occupancy?
        charge.adult + charge.single_delta
      else
        charge.adult
      end
    else
      fail_no_cost_code!(stay)
    end
  end

  def fail_no_cost_code!(stay)
    stay = (stay.housing_facility || stay).inspect

    raise NoCostCodeError,
          t('errors.no_cost_code', stay: stay, duration: stay.duration)
  end

  def charge_type(stay)
    case stay.housing_type
    when 'apartment' then 'apartment_rent'
    when 'dormitory' then 'dorm_adult'
    end
  end

  def fail_no_charge_type!(stay)
    name = (stay.housing_facility || stay).inspect
    raise NoCostTypeError,
          t('errors.no_facility_type', name: name, type: stay.housing_type)
  end

  def must_pay(stay, cost)
    cost * (stay.housing_type == 'apartment' ? stay.must_pay_ratio : 1)
  end
end
