module AccountingReport
  class Bank
    ACCOUNT_TYPES = %i[business staff cash].freeze
    PAYMENT_TYPES = {
      business: 'business_account',
      cash: %w[pre_paid credit_card cash_check].freeze
    }.freeze

    class << self
      def from_finances(finances)
        business = total_bus_payments(finances.family)
        cash = total_cash_payments(finances.family)
        staff = finances.subtotal - (business + cash)

        new(business: business, staff: staff, cash: cash)
      end

      def total_bus_payments(family)
        payments_of_type(family, PAYMENT_TYPES[:business])
          .map(&:price)
          .inject(Money.empty, :+)
      end

      def total_cash_payments(family)
        payments_of_type(family, PAYMENT_TYPES[:cash])
          .map(&:price)
          .inject(Money.empty, :+)
      end

      def payments_of_type(family, type)
        family.payments.select { |p| Array(type).include?(p.payment_type) }
      end
    end

    def initialize(business:, staff:, cash:)
      @business = business
      @staff = staff
      @cash = cash
    end

    ACCOUNT_TYPES.each do |name|
      # @return [Boolean] True if there are no funds in the given account
      define_method(:"#{name}_empty?") do
        instance_variable_get(:"@#{name}").zero?
      end

      # @return [Money] The additional funds needed to debit the given amount
      define_method(:"#{name}_needs") do |amount|
        [amount - instance_variable_get(:"@#{name}"), Money.empty].max
      end

      # @return [Boolean] Are there enough funds to debit the given amount?
      define_method(:"#{name}_enough?") do |amount|
        send(:"#{name}_needs", amount).zero?
      end

      # @raise [DebitError] if the account doesn't have enough money to cover
      #   the given amount
      define_method(:"#{name}_debit") do |amount|
        current = instance_variable_get(:"@#{name}")
        unless send(:"#{name}_enough?", amount)
          raise_error(name, amount, current)
        end
        instance_variable_set(:"@#{name}", current - amount)
      end
    end

    def raise_error(account, amount, current)
      raise DebitError,
            format("Could not debit the %s account %s (current total: %s)",
                   account, amount, current)
    end
  end

  DebitError = Class.new(StandardError)
end
