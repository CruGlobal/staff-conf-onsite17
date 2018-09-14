class Course::SumAttendeeCost < ChargesService
  attr_accessor :attendee

  def call
    charges[:tuition_class] += courses_price
    self.cost_adjustments = attendee.cost_adjustments
  end

  def courses_price
    attendee.courses.map(&:price).inject(Money.empty, &:+)
  end

  # @note The seminary price is not applied to +charges[:tuition_class]+
  #       because it may not have any such {CostAdjustment cost adjustments}
  #       applied to it
  def seminary_price
    single_seminary_price * seminary_attendances.size
  end

  private

  def seminary_attendances
    attendee.course_attendances.select(&:seminary_credit?)
  end

  def single_seminary_price
    attendee.seminary.course_price
  end
end
