class FoodHeadCount::SumDateCost < ApplicationService
  # The date to create the head count for
  attr_accessor :date

  # An optional cafeteria by which to filter the count
  attr_accessor :cafeteria

  def call
    stays = stay_scope.for_date(date)
    stays.each(&method(:count_meals_for_stay))
  end

  def head_count
    @head_count ||=
      FoodHeadCount::CafeteriaDate.new(date: date)
  end

  private

  def stay_scope
    @stays ||= Stay.in_dormitory.includes(person: :meal_exemptions,
                                          housing_unit: :housing_facility)
  end

  def count_meals_for_stay(stay)
    type = person_type(stay.person)
    return if type.blank?

    applicable_meals(stay).each { |meal| head_count.increment(type, meal) }
  end

  def person_type(person)
    age = person.age

    if age >= 11
      :adult
    elsif age >= 5
      :child
    end
  end

  def applicable_meals(stay)
    (MealExemption::TYPES - exempt_meals(stay.person)).map(&:downcase)
  end

  def exempt_meals(person)
    person.meal_exemptions.select { |me| me.date == date }.map(&:meal_type)
  end
end
