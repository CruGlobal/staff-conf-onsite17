module AccountingReport
  class Report < ApplicationService
    attr_accessor :family_id

    # An optional start date. If missing, today's date is used
    attr_accessor :start_at

    # An optional end date. If missing, the {Stay#departed_at} of the
    # most-recent dorm stay will be used
    attr_accessor :end_at

    def call
      all_rows.each { |row| table.add(row) }
    end

    def table
      @table ||= AccountingReport::Table.new
    end

    private

    def all_rows
      [
        total(AttendeeCosts),
        total(JuniorSeniorCosts),
        total(ChildcareCosts),
        total(ChildStayNonTaxableCosts),
        total(ChildStayTaxableCosts),
        total(HotLunchCosts)
      ].flatten.compact # TODO: remove .compact
    end

    def total(report_class)
      if @cached_family_id.nil? || family_id != @cached_family_id
        @family = Family.includes(:payments).find(family_id)
        @finances = FamilyFinances::Report.call(family: @family)
        @bank = Bank.from_finances(@finances)
        @cached_family_id = family_id
      end

      report_class.new(finances: @finances, bank: @bank).call
    end
  end
end
