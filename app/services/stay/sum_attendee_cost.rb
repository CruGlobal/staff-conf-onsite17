class Stay::SumAttendeeCost < ChargesService
  attr_accessor :attendee

  # +#to_s+
  #   An optional {Stay#housing_type} to filter by
  attr_accessor :housing_type

  def call
    stays.each(&method(:sum_stay_cost))

    self.cost_adjustments = attendee.cost_adjustments
  end

  private

  def stays
    if housing_type.present?
      attendee.stays.select { |s| s.housing_type == housing_type }
    else
      attendee.stays
    end
  end

  def sum_stay_cost(stay)
    cost = Stay::SingleAttendeeCost.call(stay: stay)
    charges[cost.type] += cost.total
  end
end
