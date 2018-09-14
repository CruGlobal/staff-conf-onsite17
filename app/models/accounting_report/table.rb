module AccountingReport
  class Table
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModelResourceCollection
    include Enumerable

    delegate :each, to: :rows

    class << self
      def columns
        [
          column(:bus_unit, :string),
          column(:oper_unit, :string),
          column(:dept_id, :string),
          column(:project, :string),
          column(:account, :string),
          column(:product, :string),
          column(:amount, :string),
          column(:description, :string),
          column(:reference, :string),
          column(AccountingReport::Row::NBSP_COL, :string),
          column(:family_id, :string),
          column(:last_name, :string),
          column(:first_name, :string),
          column(:spouse_first_name, :string),
        ].flatten
      end
    end

    def initialize(*_args)
      super
      @rows = []
      @next_id = 1
    end

    def rows
      start = (current_page - 1) * limit_value
      @rows[start, limit_value]
    end

    def add(row)
      @rows << row
      row.id = @next_id
      @next_id += 1
    end

    def total_count
      @rows.size
    end
  end
end
