class RecPass::SumPersonCost < ChargesService
  attr_accessor :person, :cost_adjustments

  def call
    charges[:rec_center] = applicable? ? rec_center_cost : Money.empty
    self.cost_adjustments = person.cost_adjustments
  end

  private

  def stays
    @stays ||= person.stays
  end

  def applicable?
    start_at.present? && finish_at.present?
  end

  def start_at
    dates.min
  end

  def finish_at
    dates.max
  end

  def dates
    [person.rec_pass_start_at, person.rec_pass_end_at]
  end

  def rec_center_cost
    applicable_duration * UserVariable[:rec_center_daily]
  end

  def applicable_duration
    duration.times.reject { |i| in_dorm_at?(start_at + i.days) }.size
  end

  def duration
    (finish_at - start_at).to_i + 1
  end

  def in_dorm_at?(date)
    stays.for_date(date).any?(&:dormitory?)
  end
end
