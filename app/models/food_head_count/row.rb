module FoodHeadCount
  class Row
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serializers::Xml

    attr_accessor :date, :id, :cafeteria

    AGE_GROUPS = %i[adult child].freeze
    MEAL_TYPES = %i[breakfast lunch dinner].freeze
    MEAL_COUNTS =
      AGE_GROUPS.flat_map do |age|
        MEAL_TYPES.map do |meal|
          [age, meal].join('_').to_sym.tap { |attr| attr_accessor attr }
        end
      end

    def initialize(*_args)
      super
    end

    def attributes
      Hash[
        (%i[id date] + MEAL_COUNTS).map { |name| [name, send(name)] }
      ]
    end
  end
end
