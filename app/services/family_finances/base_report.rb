module FamilyFinances
  class BaseReport < ApplicationService
    def subtotal
      cost_reports.map(&:total).inject(Money.empty, :+)
    end

    protected

    def row(description, cost)
      Row.new(description: description.to_s, price: cost)
    end
  end
end
