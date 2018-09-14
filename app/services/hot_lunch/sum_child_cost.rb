class HotLunch::SumChildCost < ChargesService
  REQUIRED_AGES = 3..4

  attr_accessor :child

  def call
    charges[:lunch] += week_charges.values.inject(Money.empty, :+)
    self.cost_adjustments = child.cost_adjustments
  end

  def week_charges
    @hot_lunch_costs ||= Hash[
      applicable_hot_lunch_indexes.map do |index|
        [index, UserVariable["hot_lunch_week_#{index}"]]
      end
    ]
  end

  private

  # Charges are applicable unless the child was in a dorm at the start of the
  # week. One exception: for children of {#REQUIRED_AGES}, charges are always
  # applicable
  def applicable_hot_lunch_indexes
    hot_lunch_start_dates.
      map { |index, date| index unless !required? && in_dorm_at?(date) }.
      compact
  end

  def required?
    REQUIRED_AGES.include?(child.age)
  end

  # @return [Hash<Integer,Date>]
  def hot_lunch_start_dates
    Hash[
      child.hot_lunch_weeks.map do |week_offset|
        [week_offset, UserVariable["hot_lunch_begin_#{week_offset}"]]
      end
    ]
  end

  def in_dorm_at?(date)
    child.stays.for_date(date).any?(&:dormitory?)
  end
end
