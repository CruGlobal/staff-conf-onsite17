class MealExemption < ApplicationRecord
  TYPES = %w[Breakfast Lunch Dinner].freeze

  belongs_to :person

  validates :meal_type, uniqueness: {
    scope: %i[person_id date], message: 'may only have one meal type per day'
  }

  # Creates a Hash table where each key is Date in which there's one or more
  # Meals. Each element is a map of meal_type to MealExemption object.
  #
  # @example
  #   Tue, 18 Apr 2017 => Breakfast -> #<MealExemption:...>
  #                       Lunch     -> #<MealExemption:...>
  #                       Dinner    -> #<MealExemption:...>
  #   Sun, 21 May 2017 => Dinner    -> #<MealExemption:...>
  #   Thu, 14 Sep 2017 => Breakfast -> #<MealExemption:...>
  #                       Dinner    -> #<MealExemption:...>
  # @return [Hash<Date, Hash<String, MealExemption>>]
  def self.order_by_date
    Hash.new { |h, v| h[v] = {} }.tap do |dates|
      all.find_each { |meal| dates[meal.date][meal.meal_type] = meal }
    end
  end
end
