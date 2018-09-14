class AccountingReport::HelperBase < ApplicationService
  CONF_ID = 'Cru17'.freeze # TODO Should this be hardcoded?
  DESCRIPTION_LENGTH = 7

  attr_accessor :finances, :bank
  def_delegator :finances, :family

  def call
    [].tap do |rows|
      rows.push(bus_debit_row, bus_credit_row)     unless bus_amount.zero?
      rows.push(staff_debit_row, staff_credit_row) unless staff_amount.zero?
    end
  end

  def bus_debit_row
    AccountingReport::Row.new(bus_debit_attributes.merge(common_attributes))
  end

  def bus_credit_row
    AccountingReport::Row.new(bus_credit_attributes.merge(common_attributes))
  end

  def staff_debit_row
    AccountingReport::Row.new(staff_debit_attributes.merge(common_attributes))
  end

  def staff_credit_row
    AccountingReport::Row.new(staff_credit_attributes.merge(common_attributes))
  end

  protected

  # Both rows provide a common description
  def description_label
    raise NotImplementedError
  end

  # @return [Hash] the key/value pairs for the Business Account "debit" row
  def bus_debit_attributes
    raise NotImplementedError
  end

  # @return [Hash] the key/value pairs for the Business Account "credit" row
  def bus_credit_attributes
    raise NotImplementedError
  end

  # @return [Hash] the key/value pairs for the Staff Account "debit" row
  def staff_debit_attributes
    raise NotImplementedError
  end

  # @return [Hash] the key/value pairs for the Staff Account "credit" row
  def staff_credit_attributes
    raise NotImplementedError
  end

  def common_attributes
    {
      description: description,
      family_id: family.id,
      last_name: family.last_name,
      first_name: family.primary_person&.first_name,
      spouse_first_name: spouse&.first_name
    }
  end

  def description
    [CONF_ID, description_label, description_staff_number].join(' ')
  end

  def description_staff_number
    if family.staff_number.present?
      format("%0#{DESCRIPTION_LENGTH}d", family.staff_number)
    else
      family.last_name[0, DESCRIPTION_LENGTH]
    end
  end

  def spouse
    (family.attendees.to_a - [family.primary_person]).first
  end

  def bus_amount
    @bus_amount ||= calc_bus_amount
  end

  def calc_bus_amount
    return Money.empty if bank.business_empty?

    staff_needed = bank.business_needs(total_cost)
    debit_amount = total_cost - staff_needed
    bank.business_debit(debit_amount)
    debit_amount
  end

  def staff_amount
    @staff_amount ||= calc_staff_amount
  end

  def calc_staff_amount
    return Money.empty unless bank.business_empty?
    return Money.empty if bank.staff_empty?

    unpaid_cost = total_cost - bus_amount

    cash_needed = bank.staff_needs(unpaid_cost)
    debit_amount = unpaid_cost - cash_needed
    bank.staff_debit(debit_amount)
    debit_amount
  end

  def business_account_payment
    @business_account_payment ||=
      family.payments
            .find_by(payment_type: Payment.payment_types['business_account'])
  end
end
