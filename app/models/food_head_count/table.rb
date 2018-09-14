module FoodHeadCount
  class Table
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModelResourceCollection
    include Enumerable

    delegate :each, to: :rows

    class << self
      def columns
        [
          column(:date, :date),
          Row::MEAL_COUNTS.map { |count| column(count, :integer) }
        ].flatten
      end
    end

    def initialize(*_args)
      super
      @rows = []
      @next_id = 0
    end

    def rows
      start = (current_page - 1) * limit_value
      @rows[start, limit_value]
    end

    def add(head_count)
      @rows << head_count
      head_count.id = @next_id
      @next_id += 1
    end

    def total_count
      @rows.size
    end
  end
end
